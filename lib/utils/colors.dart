import 'dart:ui';

class CustomColors {
  //Main
  static Color black = const Color(0xFF121212);
  static Color darkGrey = const Color(0xFF252525);
  static Color white = const Color(0xFFFFFFFF);
  //Accent
  static Color darkGreen = const Color(0xFF021B1A);
  static Color accentGreen = const Color(0xFF00DF81);
  //Alert & Status
  static Color red = const Color(0xFFD53134);
  static Color lightRed = const Color(0xFFF25A5D);
  //Grey Scale
  static Color lightGrey = const Color(0xFFF4F4F4);
  static Color grey = const Color(0xFFC0C1C0);
  static Color grey2 = const Color(0xFFA9A9A9);
  static Color grey3 = const Color(0xFF898A8D);
  static Color grey4 = const Color(0xFF888888);
  static Color mediumGrey = const Color(0xFF6C6C6C);

  //Gradient
  static List<Color> gradient = [
    const Color.fromRGBO(0, 0, 0, 0),
    const Color.fromRGBO(0, 0, 0, 0.5),
  ];

  //Folder
  static Color lightGreen = const Color(0xFFBEF6DC);
  static Color green = const Color(0xFF2CC295);
  static Color minty = const Color(0xFF56A68D);
  static Color mediumGreen = const Color(0xFF03624C);
  static Color lightOrange = const Color(0xFFFFF3E9);
  static Color mediumOrange = const Color(0xFFFFEEDE);
  static Color orange = const Color(0xFFEF7C12);
  static Color lightBlue = const Color(0xFFE5EEFF);
  static Color mediumBlue = const Color(0xFFC7DAFF);
  static Color blue = const Color(0xFF4E81E1);
  static Color lightPink = const Color(0xFFFFF3FF);
  static Color mediumPink = const Color(0xFFFEE1FF);
  static Color pink = const Color(0xFFED73F3);
  static Color lightPurple = const Color(0xFFF9F3FF);
  static Color mediumPurple = const Color(0xFFEDE1FB);
  static Color purple = const Color(0xFFE2CFFF);

  static Color folderDarkGrey = const Color(0xFF081A1A);
  static Color folderGreen500 = const Color(0xFF2CC295);
  static Color folderOrange500 = const Color(0xFFFEA622);
  static Color folderBlue500 = const Color(0xFF4D4DF6);
  static Color folderPink500 = const Color(0xFFEC5BF7);
  static Color folderPurple500 = const Color(0xFF9E65E3);
  static Color folderYellow500 = const Color(0xFF447DD2);
  static Color folderDarkGreen400 = const Color(0xFF03624C);
  static Color folderGreen400 = const Color(0xFF00DF81);
  static Color folderOrange400 = const Color(0xFFF9DCA1);
  static Color folderBlue400 = const Color(0xFF9999F8);
  static Color folderPink400 = const Color(0xFFF19EF9);
  static Color folderPurple400 = const Color(0xFFC7A6EE);
  static Color folderYellow400 = const Color(0xFF619EF7);
  static Color folderDarkGreen300 = const Color(0xFF56A68D);
  static Color folderGreen300 = const Color(0xFFBEF6DC);
  static Color folderOrange300 = const Color(0xFFFBE8C3);
  static Color folderBlue300 = const Color(0xFFC2C2FA);
  static Color folderPink300 = const Color(0xFFF6C4FB);
  static Color folderPurple300 = const Color(0xFFDDCAF5);
  static Color folderYellow300 = const Color(0xFF8FBDFF);
  static List<Color> getFolderColors() {
    return [
      folderDarkGrey,
      folderGreen500,
      folderOrange500,
      folderBlue500,
      folderPink500,
      folderPurple500,
      folderYellow500,
      folderDarkGreen400,
      folderGreen400,
      folderOrange400,
      folderBlue400,
      folderPink400,
      folderPurple400,
      folderYellow400,
      folderDarkGreen300,
      folderGreen300,
      folderOrange300,
      folderBlue300,
      folderPink300,
      folderPurple300,
      folderYellow300,
    ];
  }
}
