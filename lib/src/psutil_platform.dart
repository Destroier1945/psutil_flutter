abstract class PsutilPlatform {
  List<int> pids();
  bool pidExists(int pid);
  Map<String, double> cpuTimes();
  Map<String, int> virtualMemory();
  
  // Process specific
  String procName(int pid);
  String procExe(int pid);
  String procStatus(int pid);
  Map<String, int> procMemoryInfo(int pid);
  Map<String, double> procCpuTimes(int pid);

  // New methods
  Map<String, dynamic> netIoCounters();
  Map<String, dynamic> diskUsage(String path);
  List<Map<String, dynamic>> diskPartitions();
}
