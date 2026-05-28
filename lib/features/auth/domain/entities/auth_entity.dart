// ============================================================================
//  features/auth/domain/entities/auth_entity.dart
// ============================================================================

import 'dart:convert';
import 'package:equatable/equatable.dart';

enum UserRole { customer, artisan, admin }

class AuthEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String token;

  const AuthEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isArtisan => role == UserRole.artisan;
  bool get isAuthenticated => token.isNotEmpty;

  // 🔐 SERIALIZACIÓN
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'token': token,
    });
  }

  // 🔐 DESERIALIZACIÓN (FIX IMPORTANTE)
  factory AuthEntity.fromJson(String source) {
    final Map<String, dynamic> map = jsonDecode(source);

    return AuthEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      token: map['token']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, token];
}
