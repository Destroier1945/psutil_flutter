# psutil_flutter

A Flutter plugin for retrieving information on running processes and system utilization (CPU, memory, disks, network, sensors). Inspired by the Python `psutil` library.

## Features

- **Cross-Platform Architecture**: Clean separation of platform-specific code using `PsutilPlatform`.
- **System Information**:
    - **CPU**: System-wide CPU times and percentage (Async).
    - **Memory**: Total, free, and available virtual memory.
    - **Network**: IO counters for all network interfaces (bytes sent/received, packets, errors, etc.).
    - **Disk**: Partition listing and usage statistics (total, used, free, percentage).
- **Process Management**:
    - List all active PIDs.
    - Get process-specific details: Name, Executable path, Status, Memory Info (RSS, VMS), and CPU Times.
    - Measure individual process CPU usage percentage (Async).
- **Performance Focused**:
    - Sampling helpers like `cpuPercent` are asynchronous, but the current Linux implementation still reads `/proc` synchronously.
    - Low-level system access via **Dart FFI** and `/proc` parsing.

## Supported Platforms

| Platform | Support | Method |
| --- | --- | --- |
| **Linux** | ✅ Implemented | `/proc` & FFI (`libc`) |
| **Windows** | 🏗️ Stub only | Win32 API (Planned) |
| **macOS** | 🏗️ Stub only | IOKit / sysctl (Planned) |

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  psutil_flutter:
    path: ./path/to/psutil_flutter
```

## Usage

### System Information

```dart
import 'package:psutil_flutter/psutil_flutter.dart';

// Get CPU usage percentage (async, takes an interval)
double cpuUsage = await Psutil.cpuPercent(interval: Duration(seconds: 1));
print('CPU Usage: ${cpuUsage.toStringAsFixed(1)}%');

// Virtual Memory
var vm = Psutil.virtualMemory();
print('Total Memory: ${vm["MemTotal"]! / (1024 * 1024 * 1024)} GB');

// Network IO
var net = Psutil.netIoCounters();
print('Network Stats: $net');

// Disk Usage
var disk = Psutil.diskUsage('/');
print('Root Disk Usage: ${disk["percent"]}%');
```

### Process Information

```dart
// List all PIDs
List<int> pids = Psutil.pids();

// Get specific process
var p = Process(pids.first);
print('Process Name: ${p.name()}');
print('Memory RSS: ${p.memoryInfo()["rss"]! / (1024 * 1024)} MB');

// Measure process CPU usage
double procCpu = await p.cpuPercent(interval: Duration(milliseconds: 500));
```

## Architecture

The project uses a **Platform Interface** pattern:

1. `PsutilPlatform`: Abstract interface defining all supported operations.
2. `LinuxPsutil`: Linux implementation using `/proc` file parsing and FFI for `libc` calls (`sysconf`, `statvfs`).
3. `Psutil`: Public-facing static API that delegates to the appropriate platform implementation.

## Contributions

Contributions for Windows and macOS implementations are welcome!
