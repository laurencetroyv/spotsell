import 'dart:io';

import 'package:spotsell/src/data/entities/meta_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';

enum Condition { superNew, likeNew, good, fair, poor }

enum Status { available, solid, reserved, hidden }

class Product {
  final String id;
  final String title;
  final String description;
  final String price;
  final Condition condition;
  final Status status;
  final Store? store;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      condition: json['condition'],
      status: json['status'],
      store: Store.fromJson(json['store']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "price": price,
      "condition": condition,
      "status": status,
      "store": store,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
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

  ProductsMeta({
    super.page,
    super.perPage,
    super.search,
    super.showAll,
    super.sortBy,
    super.sortOrder,
    this.filterByCondition,
    this.filterByStatus,
  });
}

class ProductsRequest extends Product {
  final List<int>? categories;
  final List<File>? attachments;

  ProductsRequest({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.condition,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    this.attachments,
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
    super.attachments,
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
