import 'package:dart_mappable/dart_mappable.dart';
import 'package:image_picker/image_picker.dart';

class DurationMapper extends SimpleMapper<Duration> {
  @override
  Duration decode(dynamic value) {
    if (value == null) return Duration.zero;
    if (value is int) return Duration(milliseconds: value);
    if (value is String) {
      // Optional: support stringified millis
      final ms = int.tryParse(value);
      if (ms != null) return Duration(milliseconds: ms);
    }
    throw MapperException.unexpectedType(
      Duration,
      'Cannot decode Duration from $value',
    );
  }

  @override
  dynamic encode(Duration value) => value.inMilliseconds;
}

class DurationMillisHook extends MappingHook {
  const DurationMillisHook();

  @override
  dynamic beforeEncode(dynamic value) {
    if (value is Duration) return value.inMilliseconds;
    return value;
  }

  @override
  dynamic afterDecode(dynamic value) {
    if (value is int) return Duration(milliseconds: value);
    if (value == null) return Duration.zero;
    return value;
  }
}

class XFileMapper extends SimpleMapper<XFile> {
  @override
  XFile decode(dynamic value) {
    if (value is String) return XFile(value);
    return value;
  }

  @override
  dynamic encode(XFile value) => value.path;
}

class XFileHook extends MappingHook {
  const XFileHook();

  @override
  dynamic beforeEncode(dynamic value) {
    if (value is XFile) return value.path;
    return value;
  }

  @override
  dynamic afterDecode(dynamic value) {
    if (value is String) return XFile(value);
    return value;
  }
}
