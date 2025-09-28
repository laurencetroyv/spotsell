import 'package:dio/dio.dart';

import 'package:spotsell/src/data/entities/entities.dart';

enum Condition { superNew, likeNew, good, fair, poor }

enum Status { available, solid, reserved, hidden }

class Product {
  final int? id;
  final String title;
  final String description;
  final String price;
  final Condition condition;
  final Status status;
  final Store? store;
  final List<Attachment>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.store,
    this.attachments,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      condition: getCondition(json['condition']),
      status: getStatus(json['status']),
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      attachments: json['attachments'] != null
          ? List.castFrom(json['attachments'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "price": double.parse(price),
      "condition": conditions,
      "status": statuses,
      "store_id": store?.id,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  static Condition getCondition(String condition) {
    switch (condition) {
      case 'new':
        return Condition.superNew;
      case 'like_new':
        return Condition.likeNew;
      case 'good':
        return Condition.good;
      case 'fair':
        return Condition.fair;
      default:
        return Condition.poor;
    }
  }

  String get conditions {
    switch (condition) {
      case Condition.superNew:
        return 'new';
      case Condition.likeNew:
        return 'like_new';
      case Condition.good:
        return 'good';
      case Condition.fair:
        return 'fair';
      case Condition.poor:
        return 'poor';
    }
  }

  String get properCondition {
    switch (condition) {
      case Condition.superNew:
        return 'New';
      case Condition.likeNew:
        return 'Like New';
      case Condition.good:
        return 'Good';
      case Condition.fair:
        return 'Fair';
      case Condition.poor:
        return 'Poor';
    }
  }

  static Status getStatus(String status) {
    switch (status) {
      case 'available':
        return Status.available;
      case 'solid':
        return Status.solid;
      case 'reserved':
        return Status.reserved;
      default:
        return Status.hidden;
    }
  }

  String get statuses {
    switch (status) {
      case Status.available:
        return 'available';
      case Status.solid:
        return 'solid';
      case Status.reserved:
        return 'reserved';
      case Status.hidden:
        return 'hidden';
    }
  }

  String get properStatuses {
    switch (status) {
      case Status.available:
        return 'Available';
      case Status.solid:
        return 'Solid';
      case Status.reserved:
        return 'Reserved';
      case Status.hidden:
        return 'Hidden';
    }
  }
}

class ProductsMeta extends Meta {
  final List<Condition>? filterByCondition;
  final List<Status>? filterByStatus;
  final List<String>? withMeta;
  final int? storeId;

  ProductsMeta({
    super.page,
    super.perPage,
    super.search,
    super.showAll,
    super.sortBy,
    super.sortOrder,
    this.filterByCondition,
    this.filterByStatus,
    this.withMeta,
    this.storeId,
  });
}

class ProductsRequest extends Product {
  final List<int>? categories;
  final List<MultipartFile>? images;

  ProductsRequest({
    super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.condition,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    this.images,
    super.store,
    this.categories,
  });

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "categories": categories};
  }
}

class UpdateProductRequest extends ProductsRequest {
  UpdateProductRequest({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.condition,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.images,
    super.store,
    super.categories,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "price": bool.parse(price),
      "condition": conditions,
      "status": statuses,
      "categories": categories,
    };
  }
}
