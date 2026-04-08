import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'psutil_platform.dart';

// C sysconf constants
const int _SC_CLK_TCK = 2;

typedef SysconfNative = Int64 Function(Int32 name);
typedef SysconfDart = int Function(int name);

typedef GetpagesizeNative = Int32 Function();
typedef GetpagesizeDart = int Function();

// statvfs
final class StatVfs extends Struct {
  @Uint64()
  external int f_bsize;
  @Uint64()
  external int f_frsize;
  @Uint64()
  external int f_blocks;
  @Uint64()
  external int f_bfree;
  @Uint64()
  external int f_bavail;
  @Uint64()
  external int f_files;
  @Uint64()
  external int f_ffree;
  @Uint64()
  external int f_favail;
  @Uint64()
  external int f_fsid;
  @Uint64()
  external int f_flag;
  @Uint64()
  external int f_namemax;
}

typedef StatVfsNative =
    Int32 Function(Pointer<Utf8> path, Pointer<StatVfs> buf);
typedef StatVfsDart = int Function(Pointer<Utf8> path, Pointer<StatVfs> buf);

class LinuxPsutil implements PsutilPlatform {
  static const String _procfsPath = '/proc';
  late final DynamicLibrary _libc;
  late final SysconfDart _sysconf;
  late final GetpagesizeDart _getpagesize;
  late final StatVfsDart _statvfs;

  late final int _clktck;
  late final int _pageSize;

  LinuxPsutil() {
    _libc = DynamicLibrary.open('libc.so.6');
    _sysconf = _libc.lookupFunction<SysconfNative, SysconfDart>('sysconf');
    _getpagesize = _libc.lookupFunction<GetpagesizeNative, GetpagesizeDart>(
      'getpagesize',
    );
    _statvfs = _libc.lookupFunction<StatVfsNative, StatVfsDart>('statvfs');

    _clktck = _sysconf(_SC_CLK_TCK);
    _pageSize = _getpagesize();
  }

  @override
  List<int> pids() {
    final dir = Directory(_procfsPath);
    return dir
        .listSync()
        .whereType<Directory>()
        .map((d) => int.tryParse(d.path.split('/').last))
        .where((pid) => pid != null)
        .cast<int>()
        .toList();
  }

  @override
  bool pidExists(int pid) {
    return Directory('$_procfsPath/$pid').existsSync();
  }

  @override
  Map<String, double> cpuTimes() {
    final file = File('$_procfsPath/stat');
    final line = file.readAsLinesSync().first;
    final parts = line.split(RegExp(r'\s+'));
    return {
      'user': double.parse(parts[1]) / _clktck,
      'nice': double.parse(parts[2]) / _clktck,
      'system': double.parse(parts[3]) / _clktck,
      'idle': double.parse(parts[4]) / _clktck,
      'iowait': parts.length > 5 ? double.parse(parts[5]) / _clktck : 0.0,
      'irq': parts.length > 6 ? double.parse(parts[6]) / _clktck : 0.0,
      'softirq': parts.length > 7 ? double.parse(parts[7]) / _clktck : 0.0,
      'steal': parts.length > 8 ? double.parse(parts[8]) / _clktck : 0.0,
      'guest': parts.length > 9 ? double.parse(parts[9]) / _clktck : 0.0,
      'guest_nice': parts.length > 10 ? double.parse(parts[10]) / _clktck : 0.0,
    };
  }

  @override
  Map<String, int> virtualMemory() {
    final file = File('$_procfsPath/meminfo');
    final mems = <String, int>{};
    for (final line in file.readAsLinesSync()) {
      final parts = line.split(RegExp(r':\s+'));
      if (parts.length == 2) {
        final key = parts[0];
        final valueStr = parts[1].trim().split(' ').first;
        mems[key] = int.parse(valueStr) * 1024; // KB to B
      }
    }
    return mems;
  }

  @override
  String procName(int pid) {
    try {
      final file = File('$_procfsPath/$pid/comm');
      return file.readAsStringSync().trim();
    } catch (_) {
      final file = File('$_procfsPath/$pid/stat');
      final content = file.readAsStringSync();
      final match = RegExp(r'\((.*)\)').firstMatch(content);
      return match?.group(1) ?? '';
    }
  }

  @override
  String procExe(int pid) {
    return Link('$_procfsPath/$pid/exe').resolveSymbolicLinksSync();
  }

  @override
  String procStatus(int pid) {
    final file = File('$_procfsPath/$pid/status');
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('State:')) {
        return line.split(':')[1].trim();
      }
    }
    return '';
  }

  @override
  Map<String, int> procMemoryInfo(int pid) {
    final file = File('$_procfsPath/$pid/statm');
    final parts = file.readAsStringSync().split(RegExp(r'\s+'));
    return {
      'rss': int.parse(parts[1]) * _pageSize,
      'vms': int.parse(parts[0]) * _pageSize,
      'shared': int.parse(parts[2]) * _pageSize,
      'text': int.parse(parts[3]) * _pageSize,
      'lib': int.parse(parts[4]) * _pageSize,
      'data': int.parse(parts[5]) * _pageSize,
      'dirty': int.parse(parts[6]) * _pageSize,
    };
  }

  @override
  Map<String, double> procCpuTimes(int pid) {
    final file = File('$_procfsPath/$pid/stat');
    final content = file.readAsStringSync();
    final lastParen = content.lastIndexOf(')');
    final parts = content.substring(lastParen + 2).split(RegExp(r'\s+'));

    final utime = double.parse(parts[11]);
    final stime = double.parse(parts[12]);
    final cutime = double.parse(parts[13]);
    final cstime = double.parse(parts[14]);

    return {
      'user': utime / _clktck,
      'system': stime / _clktck,
      'children_user': cutime / _clktck,
      'children_system': cstime / _clktck,
    };
  }

  @override
  Map<String, dynamic> netIoCounters() {
    final file = File('$_procfsPath/net/dev');
    final lines = file.readAsLinesSync();
    final counters = <String, dynamic>{};
    // Skip headers
    for (final line in lines.skip(2)) {
      final parts = line.trim().split(RegExp(r'[:\s]+'));
      if (parts.length >= 17) {
        final name = parts[0];
        counters[name] = {
          'bytes_sent': int.parse(parts[9]),
          'bytes_recv': int.parse(parts[1]),
          'packets_sent': int.parse(parts[10]),
          'packets_recv': int.parse(parts[2]),
          'errin': int.parse(parts[3]),
          'errout': int.parse(parts[11]),
          'dropin': int.parse(parts[4]),
          'dropout': int.parse(parts[12]),
        };
      }
    }
    return counters;
  }

  @override
  Map<String, dynamic> diskUsage(String path) {
    final pathPointer = path.toNativeUtf8();
    final bufPointer = calloc<StatVfs>();
    try {
      final result = _statvfs(pathPointer, bufPointer);
      if (result != 0) {
        throw Exception('statvfs failed for $path');
      }
      final buf = bufPointer.ref;
      final total = buf.f_blocks * buf.f_frsize;
      final free = buf.f_bfree * buf.f_frsize;
      final used = total - free;
      final percent = total > 0 ? (used / total) * 100 : 0.0;

      return {'total': total, 'used': used, 'free': free, 'percent': percent};
    } finally {
      calloc.free(pathPointer);
      calloc.free(bufPointer);
    }
  }

  @override
  List<Map<String, dynamic>> diskPartitions() {
    final file = File('$_procfsPath/mounts');
    final lines = file.readAsLinesSync();
    final partitions = <Map<String, dynamic>>[];
    for (final line in lines) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        partitions.add({
          'device': parts[0],
          'mountpoint': parts[1],
          'fstype': parts[2],
          'opts': parts[3],
        });
      }
    }
    return partitions;
  }
}
