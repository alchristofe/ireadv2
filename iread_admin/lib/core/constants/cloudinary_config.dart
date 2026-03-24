class CloudinaryConfig {
  static const String cloudName = 'dgolyjwhn'; // Replace with your Cloud Name
  static const String uploadPreset =
      'iread_uploads'; // Replace with your Unsigned Upload Preset

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';
}
