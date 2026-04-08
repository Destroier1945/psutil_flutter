import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'psutil_flutter_method_channel.dart';

abstract class PsutilFlutterPlatform extends PlatformInterface {
  /// Constructs a PsutilFlutterPlatform.
  PsutilFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PsutilFlutterPlatform _instance = MethodChannelPsutilFlutter();

  /// The default instance of [PsutilFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPsutilFlutter].
  static PsutilFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PsutilFlutterPlatform] when
  /// they register themselves.
  static set instance(PsutilFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
