// ignore_for_file: avoid_print

import 'lib/psutil_flutter.dart';
import 'dart:io';

void main() async {
  print('=== System Info ===');
  print('PIDs count: ${Psutil.pids().length}');
  print('CPU Times: ${Psutil.cpuTimes()}');
  
  print('Measuring CPU Percent (async)...');
  final cpuPerc = await Psutil.cpuPercent(interval: Duration(milliseconds: 500));
  print('CPU Percent: ${cpuPerc.toStringAsFixed(2)}%');

  final vm = Psutil.virtualMemory();
  final totalMem = vm['MemTotal'] ?? vm['MemTotal:'] ?? 0;
  print('Virtual Memory: ${(totalMem / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB');

  print('\n=== Network Info ===');
  final net = Psutil.netIoCounters();
  print('Interfaces: ${net.keys.join(", ")}');
  if (net.containsKey('eth0') || net.containsKey('wlan0') || net.isNotEmpty) {
    final first = net.values.first;
    print('First Interface Stats: $first');
  }

  print('\n=== Disk Info ===');
  final partitions = Psutil.diskPartitions();
  print('Found ${partitions.length} partitions');
  final root = Psutil.diskUsage('/');
  print('Root (/) Usage: ${root["percent"].toStringAsFixed(2)}% used of ${(root["total"] / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB');

  print('\n=== Current Process ===');
  final currentPid = pid; 
  final p = Process(currentPid);
  print('Current PID: $currentPid');
  print('Name: ${p.name()}');
  print('Status: ${p.status()}');
  print('Memory Info: ${p.memoryInfo()}');
  
  print('Measuring Process CPU Percent...');
  final pCpu = await p.cpuPercent(interval: Duration(milliseconds: 500));
  print('Process CPU: ${pCpu.toStringAsFixed(2)}%');
}
