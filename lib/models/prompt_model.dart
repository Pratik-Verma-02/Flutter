import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel {
  final String promptId;
  final String uid;
  final String title;
  final String projectType;
  final String content;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? appName;
  final String? packageName;

  const PromptModel({
    required this.promptId,
    required this.uid,
    required this.title,
    required this.projectType,
    required this.content,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.appName,
    this.packageName,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      promptId: json['promptId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Prompt',
      projectType: json['projectType'] as String? ?? 'Other',
      content: json['content'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      appName: json['appName'] as String?,
      packageName: json['packageName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promptId': promptId,
      'uid': uid,
      'title': title,
      'projectType': projectType,
      'content': content,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (appName != null) 'appName': appName,
      if (packageName != null) 'packageName': packageName,
    };
  }

  PromptModel copyWith({
    String? promptId,
    String? uid,
    String? title,
    String? projectType,
    String? content,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? appName,
    String? packageName,
  }) {
    return PromptModel(
      promptId: promptId ?? this.promptId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      projectType: projectType ?? this.projectType,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
    );
  }

  String get preview {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return '';
    return lines.first.length > 100 ? '${lines.first.substring(0, 100)}...' : lines.first;
  }
}
