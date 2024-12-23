class AIModel {
  final String id;
  final String name;
  final String logo;
  final String defaultUrl;
  bool enabled;
  String? customUrl;
  String? apiKey;

  AIModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.defaultUrl,
    this.enabled = false,
    this.customUrl,
    this.apiKey,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'enabled': enabled,
    'customUrl': customUrl,
    'apiKey': apiKey,
  };

  factory AIModel.fromJson(Map<String, dynamic> json, AIModel defaultModel) => AIModel(
    id: defaultModel.id,
    name: defaultModel.name,
    logo: defaultModel.logo,
    defaultUrl: defaultModel.defaultUrl,
    enabled: json['enabled'] ?? false,
    customUrl: json['customUrl'],
    apiKey: json['apiKey'],
  );
} 