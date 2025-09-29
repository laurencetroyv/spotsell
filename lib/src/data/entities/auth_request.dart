import 'package:dio/dio.dart';

import 'package:spotsell/src/data/entities/entities.dart';

class SignInRequest {
  final String email, password;

  const SignInRequest({required this.email, required this.password});

  Map<String, String> toJson() => {'email': email, 'password': password};
}

class SignUpRequest {
  final String firstName,
      lastName,
      username,
      email,
      password,
      passwordConfirmation,
      gender,
      phone;
  final DateTime dateOfBirth;
  final List<MultipartFile>? attachments;

  const SignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
    required this.passwordConfirmation,
    required this.gender,
    this.attachments,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'gender': gender,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'phone': phone,
  };
}

class UpdateUserRequest {
  final String firstName, lastName, username, email, gender, phone;
  final DateTime dateOfBirth;
  final List<MultipartFile>? attachments;

  const UpdateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.attachments,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'gender': gender,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'phone': phone,
  };
}

class AuthUser {
  final int id;
  final String firstName, lastName, username, email, gender, phone;
  final String? token;
  final List<String>? role;
  final DateTime dateOfBirth, createdAt, updatedAt;
  final DateTime? verifiedAt;
  final List<Attachment>? attachments;

  AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.gender,
    required this.phone,
    this.role,
    required this.dateOfBirth,
    this.token,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedAt,
    this.attachments,
  });

  factory AuthUser.fromJson(
    Map<String, dynamic> json, {
    String? token,
    bool fromMessage = false,
  }) {
    final data = fromMessage ? json : json['data'];
    late List<Attachment>? attachments;

    final hasAttachments = data['attachments'] != null;

    if (hasAttachments) {
      final tmp = List.from(data['attachments']);

      attachments = tmp.map((e) => Attachment.fromJson(e)).toList();
    } else {
      attachments = null;
    }

    return AuthUser(
      id: data['id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      username: data['username'],
      email: data['email'],
      gender: data['gender'],
      phone: data['phone'],
      role: List.from(data['roles']),
      dateOfBirth: DateTime.parse(data['date_of_birth']),
      verifiedAt: data['verifiedAt'] != null
          ? DateTime.parse(data['verifiedAt'])
          : null,
      attachments: attachments,
      token: json['token'] ?? token,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  String get name => '$firstName $lastName';
}
