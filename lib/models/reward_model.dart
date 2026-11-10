class RewardModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String icon;
  final bool redeemed;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.redeemed,
  });

  factory RewardModel.fromMap(String id, Map<String, dynamic> map) {
    return RewardModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      icon: map['icon'] ?? '🎁',
      redeemed: map['redeemed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'redeemed': redeemed,
    };
  }

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    int? price,
    String? icon,
    bool? redeemed,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      redeemed: redeemed ?? this.redeemed,
    );
  }
}