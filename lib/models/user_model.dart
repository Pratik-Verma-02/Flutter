import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int credits;
  final DateTime lastResetDate;
  final int totalPrompts;
  final DateTime createdAt;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.credits,
    required this.lastResetDate,
    required this.totalPrompts,
    required this.createdAt,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      credits: json['credits'] as int? ?? 10,
      lastResetDate: json['lastResetDate'] is Timestamp
          ? (json['lastResetDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['lastResetDate']?.toString() ?? '') ?? DateTime.now(),
      totalPrompts: json['totalPrompts'] as int? ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'credits': credits,
      'lastResetDate': Timestamp.fromDate(lastResetDate),
      'totalPrompts': totalPrompts,
      'createdAt': Timestamp.fromDate(createdAt),
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? credits,
    DateTime? lastResetDate,
    int? totalPrompts,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      credits: credits ?? this.credits,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      totalPrompts: totalPrompts ?? this.totalPrompts,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
