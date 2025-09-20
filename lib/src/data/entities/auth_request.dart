import 'dart:io';

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
  final List<File>? attachments;

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
    // TODO: Add Attachments
  };
}

class Attachment {
  String id, originalName, mimeType, url;
  int fileSize;

  Attachment({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.url,
    required this.fileSize,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      originalName: json['originalName'],
      mimeType: json['mimeType'],
      url: json['url'],
      fileSize: json['fileSize'],
    );
  }
}

class AuthUser {
  final int id;
  final String firstName, lastName, username, email, gender, token, phone;
  final DateTime dateOfBirth, createdAt, updatedAt;
  final List<Attachment>? attachments;

  AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.gender,
    required this.phone,
    required this.dateOfBirth,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    this.attachments,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    late List<Attachment>? attachments;

    if (json['attachments'] != null) {
      final tmp = List.from(json['attachments']);

      attachments = tmp.map((e) => Attachment.fromJson(e)).toList();
    } else {
      attachments = null;
    }

    return AuthUser(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      gender: json['gender'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      attachments: attachments,
      token: json['token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
