class ContactPageModel {
  final String detailsEn;
  final String detailsAr;

  const ContactPageModel({
    required this.detailsEn,
    required this.detailsAr,
  });

  factory ContactPageModel.fromJson(Map<String, dynamic> json) {
    final page = json['contact_page'] as Map<String, dynamic>? ?? json;
    return ContactPageModel(
      detailsEn: page['details_en']?.toString() ?? '',
      detailsAr: page['details_ar']?.toString() ?? '',
    );
  }

  /// Returns the raw HTML content for the given locale.
  String detailsForLocale(String localeTag) {
    if (localeTag.startsWith('ar')) {
      return detailsAr;
    }
    return detailsEn;
  }
}
