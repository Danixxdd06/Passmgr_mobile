class ConfigModel {
  String masterPassword;
  String theme;
  ConfigModel({required this.masterPassword, required this.theme});

  factory ConfigModel.fromJson(Map<String, dynamic> j) => ConfigModel(
    masterPassword: j['masterPassword'] as String,
    theme: j['theme'] as String,
  );

  Map<String, dynamic> toJson() => {
    'masterPassword': masterPassword,
    'theme': theme,
  };
}
