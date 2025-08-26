class TaskType {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic> schemaDefinition;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskType({
    required this.id,
    required this.name,
    this.description,
    required this.schemaDefinition,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      schemaDefinition: json['schema_definition'] as Map<String, dynamic>,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'schema_definition': schemaDefinition,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Get field definitions from schema
  Map<String, dynamic> get fieldDefinitions {
    final properties = schemaDefinition['properties'] as Map<String, dynamic>? ?? {};
    return properties;
  }

  // Get required fields
  List<String> get requiredFields {
    final required = schemaDefinition['required'] as List<dynamic>? ?? [];
    return required.cast<String>();
  }
}