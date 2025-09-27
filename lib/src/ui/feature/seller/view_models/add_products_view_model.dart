import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/data/entities/attachments_entity.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class AddProductsViewModel extends BaseViewModel {
  late Store store;
  late final ProductRepository _productRepository;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  Condition selectedCondition = Condition.good;
  Status selectedStatus = Status.available;
  final List<ImageData> attachments = [];
  final List<int> selectedCategories = [];

  bool _isCreatingProduct = false;
  bool get isCreatingProduct => _isCreatingProduct;

  @override
  void initialize() {
    super.initialize();
    _productRepository = getService<ProductRepository>();
  }

  void setCondition(Condition? condition) {
    if (condition != null) {
      selectedCondition = condition;
      safeNotifyListeners();
    }
  }

  void setStatus(Status status) {
    selectedStatus = status;
    safeNotifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _addImageFromXFile(image);
      }
    } catch (e) {
      setError('Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _addImageFromXFile(image);
      }
    } catch (e) {
      setError('Failed to take photo: $e');
    }
  }

  Future<void> _addImageFromXFile(XFile xFile) async {
    try {
      ImageData imageData;

      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        imageData = ImageData(
          bytes: bytes,
          name: xFile.name,
          mimeType: xFile.mimeType,
        );
      } else {
        imageData = ImageData(
          file: File(xFile.path),
          name: xFile.name,
          mimeType: xFile.mimeType,
        );
      }

      if (imageData.isValid) {
        attachments.add(imageData);
        safeNotifyListeners();
      } else {
        setError('Invalid image data');
      }
    } catch (e) {
      setError('Failed to process image: $e');
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      for (final image in images) {
        await _addImageFromXFile(image);
      }
    } catch (e) {
      setError('Failed to pick images: $e');
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
      safeNotifyListeners();
    }
  }

  void clearAttachments() {
    attachments.clear();
    safeNotifyListeners();
  }

  bool get isFormValid {
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        priceController.text.trim().isNotEmpty &&
        double.tryParse(priceController.text.trim()) != null;
  }

  double get totalAttachmentSize {
    final totalBytes = attachments.fold<int>(
      0,
      (sum, image) => sum + image.size,
    );
    return totalBytes / (1024 * 1024);
  }

  bool get isAttachmentSizeValid {
    const maxSizeMB = 50;
    return totalAttachmentSize <= maxSizeMB;
  }

  Future<bool> createProduct() async {
    if (!isFormValid) {
      setError('Please fill in all required fields with valid data');
      return false;
    }

    if (!isAttachmentSizeValid) {
      setError('Total image size exceeds 50MB limit');
      return false;
    }

    _isCreatingProduct = true;
    safeNotifyListeners();

    try {
      List<MultipartFile>? multipartFiles;

      if (attachments.isNotEmpty) {
        multipartFiles = [];

        for (final imageData in attachments) {
          MultipartFile multipartFile;

          if (kIsWeb && imageData.bytes != null) {
            multipartFile = MultipartFile.fromBytes(
              imageData.bytes!,
              filename: imageData.displayName,
              contentType: DioMediaType.parse(
                imageData.mimeType ?? 'image/jpeg',
              ),
            );
          } else if (!kIsWeb && imageData.file != null) {
            multipartFile = await MultipartFile.fromFile(
              imageData.file!.path,
              filename: imageData.displayName,
              contentType: DioMediaType.parse(
                imageData.mimeType ?? 'image/jpeg',
              ),
            );
          } else {
            continue;
          }

          multipartFiles.add(multipartFile);
        }

        if (multipartFiles.isEmpty) {
          multipartFiles = null;
        }
      }

      final request = ProductsRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: priceController.text.trim(),
        condition: selectedCondition,
        status: selectedStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: store,
        attachments: multipartFiles,
        categories: selectedCategories.isNotEmpty ? selectedCategories : null,
      );

      final success = await executeAsyncResult(
        () => _productRepository.createProduct(request),
        errorMessage: 'Failed to create product',
        showLoading: false,
        onSuccess: (product) {
          _clearForm();
          showSuccessMessage('Product created successfully!');
          goBack();
        },
      );

      return success;
    } catch (e) {
      setError('Unexpected error: $e');
      return false;
    } finally {
      _isCreatingProduct = false;
      safeNotifyListeners();
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    attachments.clear();
    selectedCategories.clear();
    selectedCondition = Condition.good;
    selectedStatus = Status.available;
    clearError();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
