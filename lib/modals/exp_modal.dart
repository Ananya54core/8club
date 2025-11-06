class Experience {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;
  final int order;

  Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
    required this.order,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'image_url': imageUrl,
      'icon_url': iconUrl,
      'order': order,
    };
  }
}

class ExperienceResponse {
  final String message;
  final List<Experience> experiences;

  ExperienceResponse({
    required this.message,
    required this.experiences,
  });

  factory ExperienceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final experiencesList = data['experiences'] as List<dynamic>? ?? [];

    return ExperienceResponse(
      message: json['message'] ?? '',
      experiences: experiencesList
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}