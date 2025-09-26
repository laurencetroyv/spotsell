import 'package:spotsell/src/data/entities/auth_request.dart';

class Store {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? phone;
  final String? email;
  final AuthUser? seller;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.phone,
    this.email,
    this.seller,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      seller: json['seller'] != null
          ? AuthUser.fromJson(json['seller'], token: '')
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Store copyWith({
    int? id,
    String? name,
    String? description,
    String? phone,
    String? email,
    AuthUser? seller,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      seller: seller ?? this.seller,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, description: $description, slug: $slug, phone: $phone, email: $email, created_at: ${createdAt.toIso8601String()}, updatedAt: ${updatedAt.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, phone, email);
  }
}

class CreateStoreRequest {
  final String name;
  final String? description;
  final String? phone;
  final String? email;

  const CreateStoreRequest({
    required this.name,
    this.description,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};

    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    if (phone != null && phone!.isNotEmpty) {
      data['phone'] = phone;
    }
    if (email != null && email!.isNotEmpty) {
      data['email'] = email;
    }

    return data;
  }

  @override
  String toString() {
    return 'CreateStoreRequest(name: $name, description: $description, phone: $phone, email: $email)';
  }
}

class UpdateStoreRequest {
  final String? name;
  final String? description;
  final String? phone;
  final String? email;

  const UpdateStoreRequest({
    this.name,
    this.description,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;

    return data;
  }

  @override
  String toString() {
    return 'UpdateStoreRequest(name: $name, description: $description, phone: $phone, email: $email)';
  }
}
