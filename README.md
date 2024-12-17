# System Monitor Script

This script monitors system performance and generates reports on CPU usage, memory usage, disk space usage, and active processes. It also triggers alerts if certain usage thresholds are exceeded.

## Features
- CPU usage percentage
- Memory usage (total, used, free)
- Disk space usage (total, used, available for each mounted filesystem)
- Top 5 CPU-consuming processes
- Alert mechanism for:
  - CPU usage > 80%
  - Memory usage > 75%
  - Disk space usage > 90%
- Customizable monitoring interval and output format

## Requirements
- Bash shell
- Works on Linux or macOS systems

## Usage

### Running the Script

Make the script executable and run it:

```bash
chmod +x monitor_system.sh
./monitor_system.sh --interval [SECONDS] --format [FORMAT]
