class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;
  final String publishedAt;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
    required this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
      official: json['official'] ?? false,
      publishedAt: json['published_at'],
    );
  }

  bool get isYoutubeVideo => site.toLowerCase() == 'youtube';
  bool get isTrailer => type.toLowerCase() == 'trailer';
} 