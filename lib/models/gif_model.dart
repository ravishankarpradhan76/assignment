class GifModel {
  final String id;
  final String title;
  final String url;
  final String previewUrl;

  GifModel({
    required this.id,
    required this.title,
    required this.url,
    required this.previewUrl,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['images']['original']['url'] ?? '',
      previewUrl: json['images']['fixed_width']['url'] ?? '',
    );
  }
}