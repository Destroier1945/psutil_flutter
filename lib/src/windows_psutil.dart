import 'psutil_platform.dart';

class WindowsPsutil implements PsutilPlatform {
  @override
  List<int> pids() => throw UnimplementedError('Windows not supported yet');
  @override
  bool pidExists(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, double> cpuTimes() => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, int> virtualMemory() => throw UnimplementedError('Windows not supported yet');
  @override
  String procName(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  String procExe(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  String procStatus(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, int> procMemoryInfo(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, double> procCpuTimes(int pid) => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, dynamic> netIoCounters() => throw UnimplementedError('Windows not supported yet');
  @override
  Map<String, dynamic> diskUsage(String path) => throw UnimplementedError('Windows not supported yet');
  @override
  List<Map<String, dynamic>> diskPartitions() => throw UnimplementedError('Windows not supported yet');
}
