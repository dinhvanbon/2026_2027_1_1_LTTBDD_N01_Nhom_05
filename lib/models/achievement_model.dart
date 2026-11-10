class AchievementModel {
  final String id;
  final String title;
  final String description;
  final int requiredLevel;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredLevel,
    required this.unlocked,
  });

  factory AchievementModel.fromMap(String id, Map<String, dynamic> map) {
    return AchievementModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      requiredLevel: map['requiredLevel'] ?? 1,
      unlocked: map['unlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'requiredLevel': requiredLevel,
      'unlocked': unlocked,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredLevel,
    bool? unlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}