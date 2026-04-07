import 'dart:io';
import 'dart:async';
import 'src/psutil_platform.dart';
import 'src/linux_psutil.dart';
import 'src/windows_psutil.dart';
import 'src/macos_psutil.dart';

class Psutil {
  static final PsutilPlatform _impl = _getPlatform();

  static PsutilPlatform _getPlatform() {
    if (Platform.isLinux) return LinuxPsutil();
    if (Platform.isWindows) return WindowsPsutil();
    if (Platform.isMacOS) return MacOSPsutil();
    throw UnsupportedError('Platform not supported');
  }

  /// Returns a list of all active PIDs.
  static List<int> pids() => _impl.pids();

  /// Returns true if the PID exists.
  static bool pidExists(int pid) => _impl.pidExists(pid);

  /// Returns system-wide CPU times.
  static Map<String, double> cpuTimes() => _impl.cpuTimes();

  /// Returns system-wide virtual memory statistics.
  static Map<String, int> virtualMemory() => _impl.virtualMemory();

  static double _systemCpuTotal(Map<String, double> cpuTimes) {
    return cpuTimes['user']! +
        cpuTimes['nice']! +
        cpuTimes['system']! +
        cpuTimes['idle']! +
        cpuTimes['iowait']! +
        cpuTimes['irq']! +
        cpuTimes['softirq']! +
        cpuTimes['steal']!;
  }

  /// Returns the CPU usage as a percentage.
<<<<<<< HEAD
  /// Runs in a background Isolate to avoid blocking the UI thread.
  static Future<double> cpuPercent({
    Duration interval = const Duration(seconds: 1),
  }) async {
    // We capture the implementation because the isolate might not have access to static members the same way
    // or we might need to recreate the implementation inside the isolate.
    // For simplicity and correctness with FFI, we sample here, wait, and sample again.
=======
  static Future<double> cpuPercent({Duration interval = const Duration(seconds: 1)}) async {
>>>>>>> d0846a3 (main)
    final t1 = cpuTimes();
    await Future.delayed(interval);
    final t2 = cpuTimes();

    final idle1 = t1['idle']! + t1['iowait']!;
    final idle2 = t2['idle']! + t2['iowait']!;

    final nonIdle1 =
        t1['user']! +
        t1['nice']! +
        t1['system']! +
        t1['irq']! +
        t1['softirq']! +
        t1['steal']!;
    final nonIdle2 =
        t2['user']! +
        t2['nice']! +
        t2['system']! +
        t2['irq']! +
        t2['softirq']! +
        t2['steal']!;

    final total1 = idle1 + nonIdle1;
    final total2 = idle2 + nonIdle2;

    final totalDiff = total2 - total1;
    final idleDiff = idle2 - idle1;

    if (totalDiff <= 0) return 0.0;
    return ((totalDiff - idleDiff) / totalDiff * 100.0).clamp(0.0, 100.0);
  }

  /// Returns network IO counters for all interfaces.
  static Map<String, dynamic> netIoCounters() => _impl.netIoCounters();

  /// Returns disk usage statistics for the given path.
  static Map<String, dynamic> diskUsage(String path) => _impl.diskUsage(path);

  /// Returns a list of mounted disk partitions.
  static List<Map<String, dynamic>> diskPartitions() => _impl.diskPartitions();

  Future<dynamic> getPlatformVersion() async {}
}

class Process {
  final int pid;
  static final PsutilPlatform _impl = Psutil._impl;

  Process(this.pid) {
    if (!Psutil.pidExists(pid)) {
      throw Exception('NoSuchProcess(pid=$pid)');
    }
  }

  String name() => _impl.procName(pid);
  String exe() => _impl.procExe(pid);
  String status() => _impl.procStatus(pid);
  Map<String, int> memoryInfo() => _impl.procMemoryInfo(pid);
  Map<String, double> cpuTimes() => _impl.procCpuTimes(pid);

  /// Returns the CPU usage of this process as a percentage.
  Future<double> cpuPercent({
    Duration interval = const Duration(seconds: 1),
  }) async {
    final t1 = cpuTimes();
    final st1 = Psutil.cpuTimes();
    await Future.delayed(interval);
    final t2 = cpuTimes();
    final st2 = Psutil.cpuTimes();

    final procTotal1 = t1['user']! + t1['system']!;
    final procTotal2 = t2['user']! + t2['system']!;

    final procDiff = procTotal2 - procTotal1;
    final sysDiff = Psutil._systemCpuTotal(st2) - Psutil._systemCpuTotal(st1);

    if (sysDiff <= 0) return 0.0;

    final usage = (procDiff / sysDiff) * Platform.numberOfProcessors * 100.0;
    return usage < 0 ? 0.0 : usage;
  }

  @override
  String toString() => 'Process(pid=$pid, name=${name()}, status=${status()})';
}
