import 'dart:math';

class ImageTest {
  static String getTestImage(int width, {int height = 0}) {
    return 'https://picsum.photos/$width${height > 0 ? '/$height' : ''}?x=${Random().nextInt(100)}';
  }

  static String getTestImageAvatar({int? width}) {
    return 'https://i.pravatar.cc/${width ?? 300}?img=${Random().nextInt(60) + 1}';
  }
}