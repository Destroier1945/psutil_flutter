# psutil_flutter

A Flutter package for reading process and system information inspired by Python's `psutil`.

Today the package has a functional Linux implementation backed by `/proc` parsing and a small amount of `libc` FFI. Windows and macOS currently expose only placeholder implementations and will throw `UnimplementedError`.

## Features

- Linux system metrics:
  - CPU times via `Psutil.cpuTimes()`
  - CPU usage sampling via `Psutil.cpuPercent()`
  - Virtual memory via `Psutil.virtualMemory()`
  - Network interface counters via `Psutil.netIoCounters()`
  - Disk partitions and usage via `Psutil.diskPartitions()` and `Psutil.diskUsage()`
- Linux process metrics:
  - Enumerate PIDs with `Psutil.pids()`
  - Check existence with `Psutil.pidExists()`
  - Read name, executable, status, memory and CPU times through `Process`
  - Sample per-process CPU usage with `Process.cpuPercent()`
- Platform separation through `PsutilPlatform`
- Example app included with background snapshot collection using `Isolate.run`

## Supported Platforms

| Platform | Support | Method |
| --- | --- | --- |
| **Linux** | ✅ Implemented | `/proc` & FFI (`libc`) |
| **Windows** | 🏗️ Stub only | Throws `UnimplementedError` |
| **macOS** | 🏗️ Stub only | Throws `UnimplementedError` |

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  psutil_flutter:
    path: ./path/to/psutil_flutter
```

## API Overview

The public API is synchronous for direct reads and asynchronous for sampled percentages:

```dart
import 'package:psutil_flutter/psutil_flutter.dart';

final pids = Psutil.pids();
final memory = Psutil.virtualMemory();
final disk = Psutil.diskUsage('/');

final process = Process(pids.first);
final cpu = await Psutil.cpuPercent(interval: const Duration(milliseconds: 200));
final processCpu = await process.cpuPercent(
  interval: const Duration(milliseconds: 200),
);
```

## Usage

### System Information

```dart
import 'package:psutil_flutter/psutil_flutter.dart';

final cpuUsage = await Psutil.cpuPercent(
  interval: const Duration(seconds: 1),
);
print('CPU Usage: ${cpuUsage.toStringAsFixed(1)}%');

final vm = Psutil.virtualMemory();
print('Total Memory: ${vm["MemTotal"]! / (1024 * 1024 * 1024)} GB');

final cpuTimes = Psutil.cpuTimes();
print('CPU times: $cpuTimes');

final net = Psutil.netIoCounters();
print('Network Stats: $net');

final partitions = Psutil.diskPartitions();
print('Partitions: $partitions');

final disk = Psutil.diskUsage('/');
print('Root Disk Usage: ${disk["percent"]}%');
```

### Process Information

```dart
final pids = Psutil.pids();

final p = Process(pids.first);
print('Process Name: ${p.name()}');
print('Executable: ${p.exe()}');
print('Status: ${p.status()}');
print('Memory RSS: ${p.memoryInfo()["rss"]! / (1024 * 1024)} MB');
print('CPU Times: ${p.cpuTimes()}');

final procCpu = await p.cpuPercent(
  interval: const Duration(milliseconds: 500),
);
print('Process CPU: ${procCpu.toStringAsFixed(1)}%');
```

## UI Responsiveness

The Linux implementation reads `/proc` synchronously. That is fine for scripts, tests, or occasional reads, but repeated polling from a widget tree should be moved off the main isolate.

The bundled example app does this by collecting a serializable snapshot in `Isolate.run` before calling `setState`.

```dart
final snapshot = await Isolate.run(() async {
  final cpu = await Psutil.cpuPercent(
    interval: const Duration(milliseconds: 100),
  );
  final vm = Psutil.virtualMemory();
  return (cpu: cpu, vm: vm);
});
```

## Notes

- `Psutil.cpuPercent()` and `Process.cpuPercent()` are sampled values, so they always wait for the requested interval.
- `Process.cpuPercent()` scales by the number of logical CPUs, so a process saturating one core can report close to `100%` on multicore machines.
- `diskUsage()` reports free space using blocks available to the current user, not reserved blocks available only to root.

## Architecture

The package uses a small platform abstraction:

1. `PsutilPlatform`: abstract interface for supported operations.
2. `LinuxPsutil`: Linux implementation using `/proc` and `libc`.
3. `Psutil` and `Process`: public-facing Dart API.

## Contributions

Contributions for Windows and macOS implementations are welcome!
