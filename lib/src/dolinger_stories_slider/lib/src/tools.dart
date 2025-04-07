import 'package:path/path.dart' as p;

enum kSize { small, medium, large, original }

abstract class Tools {
  static String formatImage(String url, kSize size) {
    if (url.contains('-placeholder-')) {
      return url;
    }
    final pathWithoutExt = p.withoutExtension(url);
    var ext = p.extension(url);
    var imageURL = url;
    if (ext == '.jpeg') {
      ext = '.jpg';
    } else if (ext == '.webp') {
      ext = '.jpg';
    }
    switch (size) {
      case kSize.large:
        imageURL = '$pathWithoutExt-large$ext';
        break;
      case kSize.small:
        imageURL = '$pathWithoutExt-small$ext';
        break;
      case kSize.medium:
        imageURL = '$pathWithoutExt-medium$ext';
        break;
      default: // kSize.medium:e
        imageURL = url;
        break;
    }
    return imageURL;
  }
}
