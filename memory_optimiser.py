#!/usr/bin/env python3
"""
macOS Memory Optimiser

Continuously monitors memory usage and can free up unused memory
to improve system performance.

This script:
1. Monitors memory usage at regular intervals
2. When memory usage exceeds a threshold, it can free up inactive memory
3. Can run in notification-only mode or auto-optimisation mode
4. Logs all activities and memory stats
"""

import psutil
import time
import datetime
import os
import logging
import platform
import subprocess
import argparse
from pathlib import Path

# Set up logging
log_dir = Path("logs")
log_dir.mkdir(exist_ok=True)
log_file = log_dir / "memory_optimiser.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)

# Configuration
DEFAULT_INTERVAL = 300  # seconds between checks (5 minutes)
DEFAULT_MEMORY_THRESHOLD = 75.0  # % memory usage to trigger optimisation
DEFAULT_AUTO_OPTIMISE = False  # whether to automatically optimise or just notify

def get_memory_info():
    """Get detailed memory information"""
    memory = psutil.virtual_memory()

    # Calculate additional memory metrics
    active = memory.active / (1024**3)
    inactive = memory.inactive / (1024**3) if hasattr(memory, 'inactive') else 0
    wired = memory.wired / (1024**3) if hasattr(memory, 'wired') else 0

    return {
        'percent': memory.percent,
        'total': memory.total / (1024**3),  # Convert to GB
        'used': memory.used / (1024**3),
        'free': memory.available / (1024**3),
        'active': active,
        'inactive': inactive,
        'wired': wired
    }

def optimise_memory():
    """Free up inactive memory using the purge command"""
    if platform.system() != "Darwin":
        logging.warning("Memory optimisation is only supported on macOS")
        return False, "Memory optimisation is only supported on macOS"

    try:
        # Note: purge requires sudo privileges
        logging.info("Attempting to free up inactive memory...")

        # We'll use a subprocess call that prompts for sudo password
        result = subprocess.run(
            ["sudo", "purge"],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            return True, "Successfully freed up inactive memory"
        else:
            return False, f"Failed to free up memory: {result.stderr}"
    except Exception as e:
        return False, f"Error optimising memory: {str(e)}"

def notify_user(message):
    """Send a notification to the user"""
    if platform.system() == "Darwin":
        # Use osascript to send a notification on macOS
        apple_script = f'display notification "{message}" with title "Memory Optimiser"'
        subprocess.run(["osascript", "-e", apple_script])
    else:
        # Just log the message on other platforms
        logging.info(f"Notification: {message}")

def check_and_optimise_memory(memory_threshold, auto_optimise):
    """Check memory usage and optimise if needed"""
    memory_info = get_memory_info()

    # Log current memory status
    logging.info(
        f"Memory Status: {memory_info['percent']:.1f}% used "
        f"({memory_info['used']:.2f}GB/{memory_info['total']:.2f}GB) - "
        f"Free: {memory_info['free']:.2f}GB, "
        f"Active: {memory_info['active']:.2f}GB, "
        f"Inactive: {memory_info['inactive']:.2f}GB, "
        f"Wired: {memory_info['wired']:.2f}GB"
    )

    # Check if optimisation is needed
    if memory_info['percent'] >= memory_threshold:
        logging.warning(f"Memory usage ({memory_info['percent']:.1f}%) exceeds threshold ({memory_threshold}%)")

        if auto_optimise:
            # Automatically optimise memory
            success, message = optimise_memory()
            if success:
                # Get updated memory info after optimisation
                new_memory_info = get_memory_info()
                memory_freed = new_memory_info['free'] - memory_info['free']

                optimisation_message = f"Memory optimised: {memory_freed:.2f}GB freed"
                logging.info(optimisation_message)
                notify_user(optimisation_message)
            else:
                logging.error(message)
                notify_user(f"Failed to optimise memory: {message}")
        else:
            # Just notify the user
            notify_user(f"Memory usage is high: {memory_info['percent']:.1f}%. Consider freeing up memory.")
            logging.info("Notification sent to user about high memory usage")

def main():
    parser = argparse.ArgumentParser(description='macOS Memory Optimiser')
    parser.add_argument('--interval', type=int, default=DEFAULT_INTERVAL,
                        help=f'Check interval in seconds (default: {DEFAULT_INTERVAL})')
    parser.add_argument('--threshold', type=float, default=DEFAULT_MEMORY_THRESHOLD,
                        help=f'Memory usage threshold percentage (default: {DEFAULT_MEMORY_THRESHOLD})')
    parser.add_argument('--auto', action='store_true', default=DEFAULT_AUTO_OPTIMISE,
                        help='Automatically optimise memory when threshold is exceeded')
    parser.add_argument('--test', action='store_true', help='Run in test mode to simulate memory optimisation')

    args = parser.parse_args()

    # Check if running on macOS
    if platform.system() != "Darwin":
        logging.warning("This tool is designed for macOS. Some features may not work on other platforms.")

    # Test mode
    if args.test:
        print("\n=== Memory Optimiser Test Mode ===\n")
        memory_info = get_memory_info()
        print(f"Current Memory Status:")
        print(f"  Total Memory: {memory_info['total']:.2f} GB")
        print(f"  Used Memory: {memory_info['used']:.2f} GB ({memory_info['percent']:.1f}%)")
        print(f"  Free Memory: {memory_info['free']:.2f} GB")
        print(f"  Active Memory: {memory_info['active']:.2f} GB")
        print(f"  Inactive Memory: {memory_info['inactive']:.2f} GB")
        print(f"  Wired Memory: {memory_info['wired']:.2f} GB")
        print("\nSimulating high memory usage detection...")
        print(f"WARNING: Memory usage ({memory_info['percent']:.1f}%) exceeds threshold (75.0%)")

        # Simulate user prompt
        print("\n=== User Notification ===")
        print("Memory usage is high: 75.2%. Consider freeing up memory.")

        # Simulate user choice
        print("\nWould you like to optimise memory now? (y/n): ", end="")
        choice = input().lower()

        if choice == 'y':
            print("\nAttempting to free up inactive memory...")
            print("Password: [sudo password prompt would appear here]")
            print("\nSuccessfully freed up inactive memory")
            print("Memory optimised: 2.34 GB freed")
        else:
            print("\nMemory optimisation cancelled")

        print("\nTest completed. Exiting...")
        return

    logging.info("Memory Optimiser started")
    logging.info(f"System: {platform.system()} {platform.release()}")
    logging.info(f"Monitoring interval: {args.interval} seconds")
    logging.info(f"Memory threshold: {args.threshold}%")
    logging.info(f"Auto-optimisation: {'Enabled' if args.auto else 'Disabled'}")
    logging.info("-" * 80)

    try:
        while True:
            check_and_optimise_memory(args.threshold, args.auto)
            time.sleep(args.interval)
    except KeyboardInterrupt:
        logging.info("Memory Optimiser stopped by user")
    except Exception as e:
        logging.error(f"Unexpected error: {str(e)}")
    finally:
        logging.info("Memory Optimiser ended")

if __name__ == "__main__":
    main()