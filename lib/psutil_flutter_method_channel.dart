import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'psutil_flutter_platform_interface.dart';

/// An implementation of [PsutilFlutterPlatform] that uses method channels.
class MethodChannelPsutilFlutter extends PsutilFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('psutil_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
