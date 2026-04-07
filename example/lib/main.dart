import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:psutil_flutter/psutil_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psutil Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _cpuPercent = 0.0;
  String _totalMemory = '';
  String _availableMemory = '';
  String _netStats = '';
  String _diskUsage = '';
  List<_ProcessInfo> _processes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateStats();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateStats();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateStats() async {
    final snapshot = await _collectDashboardSnapshot();

    if (!mounted) return;

    setState(() {
      _cpuPercent = snapshot.cpuPercent;
      _totalMemory = snapshot.totalMemory;
      _availableMemory = snapshot.availableMemory;
      _netStats = snapshot.netStats;
      _diskUsage = snapshot.diskUsage;
      _processes = snapshot.processes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Psutil Flutter Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatCard('CPU', '${_cpuPercent.toStringAsFixed(1)}%', Colors.orange),
                  _buildStatCard('Total Memory', _totalMemory, Colors.blue),
                  _buildStatCard('Avail Memory', _availableMemory, Colors.green),
                  _buildStatCard('Network (1st IF)', _netStats, Colors.purple),
                  _buildStatCard('Disk (/)', _diskUsage, Colors.brown),
                ],
              ),
            ),
            const Divider(),
            const Text('Top 20 Processes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _processes.length,
              itemBuilder: (context, index) {
                final p = _processes[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(p.pid.toString(), style: const TextStyle(fontSize: 10))),
                  title: Text(p.name),
                  subtitle: Text(p.status),
                  trailing: Text(p.rssLabel),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

Future<_DashboardSnapshot> _collectDashboardSnapshot() {
  return Isolate.run(() async {
    final cpu = await Psutil.cpuPercent(
      interval: const Duration(milliseconds: 100),
    );
    final vm = Psutil.virtualMemory();
    final net = Psutil.netIoCounters();
    final disk = Psutil.diskUsage('/');

    final total = (vm['MemTotal'] ?? 0) / (1024 * 1024 * 1024);
    final avail = (vm['MemAvailable'] ?? vm['MemFree'] ?? 0) /
        (1024 * 1024 * 1024);

    var netInfo = 'N/A';
    if (net.isNotEmpty) {
      final first = net.values.first as Map<String, dynamic>;
      netInfo =
          'Sent: ${((first['bytes_sent'] as int) / (1024 * 1024)).toStringAsFixed(1)} MB / '
          'Recv: ${((first['bytes_recv'] as int) / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    final processes = <_ProcessInfo>[];
    for (final pid in Psutil.pids().take(20)) {
      try {
        final process = Process(pid);
        final rss = (process.memoryInfo()['rss']! / (1024 * 1024))
            .toStringAsFixed(1);
        processes.add(
          _ProcessInfo(
            pid: pid,
            name: process.name(),
            status: process.status(),
            rssLabel: '$rss MB',
          ),
        );
      } catch (_) {}
    }

    return _DashboardSnapshot(
      cpuPercent: cpu,
      totalMemory: '${total.toStringAsFixed(2)} GB',
      availableMemory: '${avail.toStringAsFixed(2)} GB',
      netStats: netInfo,
      diskUsage:
          '${(disk['percent'] as double).toStringAsFixed(1)}% of ${((disk['total'] as int) / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB',
      processes: processes,
    );
  });
}

class _DashboardSnapshot {
  const _DashboardSnapshot({
    required this.cpuPercent,
    required this.totalMemory,
    required this.availableMemory,
    required this.netStats,
    required this.diskUsage,
    required this.processes,
  });

  final double cpuPercent;
  final String totalMemory;
  final String availableMemory;
  final String netStats;
  final String diskUsage;
  final List<_ProcessInfo> processes;
}

class _ProcessInfo {
  const _ProcessInfo({
    required this.pid,
    required this.name,
    required this.status,
    required this.rssLabel,
  });

  final int pid;
  final String name;
  final String status;
  final String rssLabel;
}
