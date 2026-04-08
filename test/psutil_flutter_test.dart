import 'package:flutter_test/flutter_test.dart';
import 'package:psutil_flutter/psutil_flutter.dart';
import 'package:psutil_flutter/psutil_flutter_platform_interface.dart';
import 'package:psutil_flutter/psutil_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPsutilFlutterPlatform
    with MockPlatformInterfaceMixin
    implements PsutilFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PsutilFlutterPlatform initialPlatform = PsutilFlutterPlatform.instance;

  test('$MethodChannelPsutilFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPsutilFlutter>());
  });

  test('getPlatformVersion', () async {
    Psutil psutilFlutterPlugin = Psutil();
    MockPsutilFlutterPlatform fakePlatform = MockPsutilFlutterPlatform();
    PsutilFlutterPlatform.instance = fakePlatform;

    expect(await psutilFlutterPlugin.getPlatformVersion(), '42');
  });
}
