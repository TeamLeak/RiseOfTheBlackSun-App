class Cosmetic {
  final String id;
  final DateTime uploadDate;
  final DateTime updatedAt;
  final String name;
  final String type; // 'skin' or 'cape'
  final String url;
  final bool active;

  Cosmetic({
    required this.id,
    required this.uploadDate,
    required this.updatedAt,
    required this.name,
    required this.type,
    required this.url,
    required this.active,
  });

  factory Cosmetic.fromJson(Map<String, dynamic> json) {
    return Cosmetic(
      id: json['id'],
      uploadDate: DateTime.parse(json['uploadDate']),
      updatedAt: DateTime.parse(json['updatedAt']),
      name: json['name'],
      type: json['type'],
      url: json['url'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploadDate': uploadDate.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'name': name,
      'type': type,
      'url': url,
      'active': active,
    };
  }
}
