@JS()
library jquery;

import 'package:js/js.dart';

@JS()
class jQuery {
  external factory jQuery(String selector);
  external int get length;
  external jQuery css(CssOptions options);
  external jQuery animate(AnimateOptions options);
  external jQuery remove();
}

@JS()
@anonymous // This annotation is needed along with the unnamed factory constructor
class CssOptions {
  external factory CssOptions(
      {backgroundColor, height, position, width, background});
  external String get backgroundColor;
  external String get position;
  external String get background;
  external num get height;
  external num get width;
}

@JS()
@anonymous
class AnimateOptions {
  external factory AnimateOptions({left, top});
  external dynamic get left;
  external dynamic get top;
}
