/// Asset paths - centralized for easy maintenance
class AssetPaths {
  AssetPaths._();

  // Images
  static const String _imagesPath = 'assets/images';
  static const String bgPattern = '$_imagesPath/bg_pattern.webp';
  static const String bgHeroLogin = '$_imagesPath/bg_hero_login.jpg';
  static const String bgHeroOnboarding = '$_imagesPath/bg_hero_onboarding.jpg';

  // Data (JSON)
  static const String _dataPath = 'assets/data';
  static const String destinationData = '$_dataPath/destination_data.json';
  static const String guideData = '$_dataPath/guide_data.json';
  static const String orderData = '$_dataPath/order_data.json';

  // Icons (SVG)
  static const String _iconsPath = 'assets/icons';
  static const String iconGoogle = '$_iconsPath/google.svg';
  static const String iconFacebook = '$_iconsPath/facebook.svg';
  static const String iconApple = '$_iconsPath/apple.svg';

  // Fonts
  static const String fontPoppins = 'Poppins';
}
