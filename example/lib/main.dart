import 'package:flutter/material.dart';
import 'dart:async';
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
  List<Process> _processes = [];
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
    final cpu = await Psutil.cpuPercent(interval: const Duration(milliseconds: 100));
    final vm = Psutil.virtualMemory();
    final net = Psutil.netIoCounters();
    final disk = Psutil.diskUsage('/');

    final total = (vm['MemTotal'] ?? 0) / (1024 * 1024 * 1024);
    final avail = (vm['MemAvailable'] ?? vm['MemFree'] ?? 0) / (1024 * 1024 * 1024);
    
    String netInfo = 'N/A';
    if (net.isNotEmpty) {
      final first = net.values.first;
      netInfo = 'Sent: ${(first["bytes_sent"] / (1024 * 1024)).toStringAsFixed(1)} MB / Recv: ${(first["bytes_recv"] / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    final pids = Psutil.pids().take(20);
    final procs = <Process>[];
    for (final pid in pids) {
      try {
        procs.add(Process(pid));
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _cpuPercent = cpu;
      _totalMemory = '${total.toStringAsFixed(2)} GB';
      _availableMemory = '${avail.toStringAsFixed(2)} GB';
      _netStats = netInfo;
      _diskUsage = '${disk["percent"].toStringAsFixed(1)}% of ${(disk["total"] / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      _processes = procs;
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
                  title: Text(p.name()),
                  subtitle: Text(p.status()),
                  trailing: Text('${(p.memoryInfo()['rss']! / (1024 * 1024)).toStringAsFixed(1)} MB'),
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
