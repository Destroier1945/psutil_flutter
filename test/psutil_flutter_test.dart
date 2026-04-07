import 'package:flutter_test/flutter_test.dart';
import 'package:psutil_flutter/psutil_flutter.dart';
<<<<<<< HEAD
import 'package:psutil_flutter/psutil_flutter_platform_interface.dart';
import 'package:psutil_flutter/psutil_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPsutilFlutterPlatform
    with MockPlatformInterfaceMixin
    implements PsutilFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}
=======
import 'dart:io';
>>>>>>> d0846a3 (main)

void main() {
  test('Psutil.pids() returns a list of integers', () {
    if (Platform.isLinux) {
      final pids = Psutil.pids();
      expect(pids, isA<List<int>>());
      expect(pids.isNotEmpty, true);
    }
  });

<<<<<<< HEAD
  test('getPlatformVersion', () async {
    Psutil psutilFlutterPlugin = Psutil();
    MockPsutilFlutterPlatform fakePlatform = MockPsutilFlutterPlatform();
    PsutilFlutterPlatform.instance = fakePlatform;
=======
  test('Psutil.virtualMemory() returns memory info', () {
    if (Platform.isLinux) {
      final vm = Psutil.virtualMemory();
      expect(vm.containsKey('MemTotal'), true);
      expect(vm['MemTotal'], isA<int>());
    }
  });
>>>>>>> d0846a3 (main)

  test('Process class name and status', () {
    if (Platform.isLinux) {
      final currentPid = pid;
      final p = Process(currentPid);
      expect(p.name().isNotEmpty, true);
      expect(p.status().isNotEmpty, true);
    }
  });

  test('Psutil.diskUsage() returns usable filesystem stats', () {
    if (Platform.isLinux) {
      final disk = Psutil.diskUsage('/');
      expect(disk['total'], isA<int>());
      expect(disk['free'], isA<int>());
      expect(disk['used'], isA<int>());
      expect(disk['percent'], isA<double>());
      expect(disk['total'] >= disk['free'], true);
    }
  });

  test('Process.cpuPercent() returns a non-negative value', () async {
    if (Platform.isLinux) {
      final p = Process(pid);
      final value = await p.cpuPercent(
        interval: const Duration(milliseconds: 50),
      );
      expect(value >= 0, true);
    }
  });
}
