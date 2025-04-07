class StoriesModel {
  StoriesModel({
    required this.title,
    required this.image,
    required this.description,
    this.screenTime,
    this.isStories,
    this.video,
    this.innerBanners,
    this.isShown = false,
    required this.imageType,
    required this.buttonText,
  });

  final String title;
  final String description;
  final int? isStories;
  final int? screenTime;
  final String? buttonText;

  final String image;
  final String imageType;
  final String? video;
  final List<StoriesModel>? innerBanners;
  bool isShown = false;

  static StoriesModel fromJson({required Map<String, dynamic> json}) {
    List<StoriesModel> innerBanners = [];
    if (json['inner_banners'] != null) {
      innerBanners = List.generate(json['inner_banners'].length,
          (index) => StoriesModel.fromJson(json: json['inner_banners'][index]));
    }
    return StoriesModel(
      title: json['title'],
      image: json['image'].toString(),
      isStories: json['is_stories'],
      imageType: json['image_type'],
      video: json['stories_video']?['url'],
      screenTime: int.tryParse(json['screen_time'] ?? '15000'),
      description: json['description'],
      buttonText: json["text_button"],
      innerBanners: innerBanners,
      isShown: false,
    );
  }
}
