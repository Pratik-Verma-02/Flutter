class PromptRequestModel {
  final String projectType;
  final String appName;
  final String? packageName;
  final String? versionName;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String description;

  const PromptRequestModel({
    required this.projectType,
    required this.appName,
    this.packageName,
    this.versionName,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectType': projectType,
      'appName': appName,
      if (packageName != null && packageName!.isNotEmpty) 'packageName': packageName,
      if (versionName != null && versionName!.isNotEmpty) 'versionName': versionName,
      if (primaryColor != null) 'primaryColor': primaryColor,
      if (secondaryColor != null) 'secondaryColor': secondaryColor,
      if (accentColor != null) 'accentColor': accentColor,
      'description': description,
    };
  }

  PromptRequestModel copyWith({
    String? projectType,
    String? appName,
    String? packageName,
    String? versionName,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? description,
  }) {
    return PromptRequestModel(
      projectType: projectType ?? this.projectType,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      versionName: versionName ?? this.versionName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      description: description ?? this.description,
    );
  }
}
