# macOS Memory Optimiser

A tool that monitors memory usage on macOS and can automatically free up unused memory to improve system performance.

## Overview

This tool helps maintain optimal system performance by:

1. Monitoring memory usage at regular intervals
2. Freeing up inactive memory when usage exceeds a threshold
3. Providing both automatic and manual optimisation options
4. Sending notifications when memory usage is high

## How It Works

On macOS, memory is categorized into different types:
- **Active memory**: Currently being used by applications
- **Wired memory**: Required by the system and cannot be freed
- **Inactive memory**: Previously used but can be reclaimed when needed
- **Free memory**: Available for immediate use

Over time, macOS may keep a lot of inactive memory that isn't immediately needed. The `purge` command forces the system to free up inactive memory, which can improve performance when memory usage is high.

## Files in this Directory

- **memory_optimiser.py**: The main Python script that monitors and optimises memory
- **start_memory_optimiser.sh**: A shell script to easily launch the optimiser with different configurations
- **install_memory_optimiser.sh**: An installation script that sets up the optimiser on your system
- **README.md**: This file (comprehensive documentation)

## Requirements

- macOS (the `purge` command is macOS-specific)
- Python 3.6+
- psutil library (`pip install psutil`)

## Quick Start

### Option 1: Run Directly

You can run the memory optimiser directly from this directory:

```bash
# Make scripts executable
chmod +x memory_optimiser.py
chmod +x start_memory_optimiser.sh

# Run with default settings (monitor only)
./start_memory_optimiser.sh

# Run with automatic optimisation
./start_memory_optimiser.sh --auto

# Run with custom settings
./start_memory_optimiser.sh --interval 120 --threshold 70 --auto

# Run in test mode to see the interface
./start_memory_optimiser.sh --test
```

### Option 2: Install System-wide

To install the memory optimiser on your system:

```bash
# Make the installation script executable
chmod +x install_memory_optimiser.sh

# Run the installation script
./install_memory_optimiser.sh
```

This will:
- Copy the files to ~/memory-optimiser/
- Add an alias to your shell profile
- Optionally set up automatic startup at login

After installation, you can run the optimiser by typing `memory-optimiser` in your terminal.

## Available Modes

The memory optimiser comes with several preset modes:

- **Default Mode**: Checks memory usage every 5 minutes and notifies you when it exceeds 75%
  ```bash
  ./start_memory_optimiser.sh
  ```

- **Monitor Mode**: Checks memory usage every minute and notifies you when it exceeds 50%
  ```bash
  ./start_memory_optimiser.sh --monitor
  ```

- **Gentle Mode**: Conservative settings (threshold: 85%, interval: 10 min)
  ```bash
  ./start_memory_optimiser.sh --gentle
  ```

- **Aggressive Mode**: Aggressive optimisation (threshold: 65%, interval: 2 min, auto)
  ```bash
  ./start_memory_optimiser.sh --aggressive
  ```

- **Test Mode**: Simulates the interface without actually monitoring or optimising memory
  ```bash
  ./start_memory_optimiser.sh --test
  ```

You can also run any of these modes in the background:
```bash
./start_memory_optimiser.sh --gentle --background
```

## Usage Examples

```bash
# Monitor memory usage every minute, notify when above 50%
./start_memory_optimiser.sh --monitor

# Conservative settings, run in background
./start_memory_optimiser.sh --gentle --background

# Aggressive optimisation, check every 2 minutes, auto-optimise at 65%
./start_memory_optimiser.sh --aggressive

# Test mode to simulate the interface
./start_memory_optimiser.sh --test
```

## Advanced Usage

### Direct Python Script Usage

You can also run the Python script directly:

```bash
python3 memory_optimiser.py
```

By default, the script will:
- Monitor memory usage every 5 minutes
- Alert you when memory usage exceeds 75%
- Only notify you without automatically freeing memory

### Command-line Options for Python Script

```
usage: memory_optimiser.py [-h] [--interval INTERVAL] [--threshold THRESHOLD] [--auto] [--test]

macOS Memory Optimiser

optional arguments:
  -h, --help            show this help message and exit
  --interval INTERVAL   Check interval in seconds (default: 300)
  --threshold THRESHOLD
                        Memory usage threshold percentage (default: 75.0)
  --auto                Automatically optimise memory when threshold is exceeded
  --test                Run in test mode to simulate memory optimisation
```

### Examples with Python Script

Monitor every minute and notify when memory exceeds 70%:
```bash
python3 memory_optimiser.py --interval 60 --threshold 70
```

Automatically free up memory when it exceeds 80%:
```bash
python3 memory_optimiser.py --threshold 80 --auto
```

## Test Mode

The test mode allows you to see what the interface would look like when the memory optimiser detects high memory usage. It shows:

1. Current memory status (total, used, free, active, inactive, and wired memory)
2. A simulated high memory usage warning
3. A prompt asking if you want to optimise memory
4. A simulation of what happens when you choose to optimise or not

This is useful for understanding how the tool works without waiting for high memory usage to occur.

To run the test mode:
```bash
./start_memory_optimiser.sh --test
```

Or directly with the Python script:
```bash
python3 memory_optimiser.py --test
```

## Running in the Background

To run the script in the background:

```bash
nohup python3 memory_optimiser.py --auto > /dev/null 2>&1 &
```

Or using the launcher script:

```bash
./start_memory_optimiser.sh --auto --background
```

To stop the background process:

```bash
pkill -f memory_optimiser.py
```

## Sudo Password Requirement

The `purge` command requires sudo privileges. When running in auto-optimisation mode, you'll be prompted for your password when needed.

If you want to run this script without password prompts, you can configure sudo to allow the `purge` command without a password by editing your sudoers file:

1. Run `sudo visudo` to edit the sudoers file
2. Add the following line (replace `yourusername` with your actual username):
   ```
   yourusername ALL=(ALL) NOPASSWD: /usr/sbin/purge
   ```

**Warning**: Modifying the sudoers file can be dangerous. Only do this if you understand the security implications.

## Logs

The script creates logs in the `logs` directory:
- `memory_optimiser.log`: Contains detailed information about memory usage and optimisation activities

## Disclaimer

While freeing up inactive memory can temporarily improve performance, macOS memory management is designed to use available memory efficiently. Frequent use of the `purge` command may not always be beneficial for overall system performance.

Use this tool when you notice your system becoming sluggish due to high memory usage, particularly after running memory-intensive applications.

## License

This software is provided as-is under the MIT License.