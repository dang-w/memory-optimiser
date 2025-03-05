#!/bin/bash
# Script to easily launch the macOS Memory Optimiser with different configurations

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Default settings
INTERVAL=300
THRESHOLD=75
AUTO=false
BACKGROUND=false
TEST=false

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -i, --interval SECONDS   Set check interval in seconds (default: 300)"
    echo "  -t, --threshold PERCENT  Set memory threshold percentage (default: 75)"
    echo "  -a, --auto               Enable automatic memory optimisation"
    echo "  -b, --background         Run in background"
    echo "  --test                   Run in test mode to simulate memory optimisation"
    echo "  -h, --help               Show this help message"
    echo
    echo "Preset modes:"
    echo "  --gentle                 Run with conservative settings (threshold: 85%, interval: 10 min)"
    echo "  --aggressive             Run with aggressive settings (threshold: 65%, interval: 2 min, auto)"
    echo "  --monitor                Monitor only, no auto-optimisation (threshold: 50%, interval: 1 min)"
    echo
    echo "Examples:"
    echo "  $0 --gentle --background     Run gentle mode in background"
    echo "  $0 -t 80 -a                  Run with 80% threshold and auto-optimisation"
    echo "  $0 --test                    Run in test mode to simulate the interface"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -t|--threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        -a|--auto)
            AUTO=true
            shift
            ;;
        -b|--background)
            BACKGROUND=true
            shift
            ;;
        --test)
            TEST=true
            shift
            ;;
        --gentle)
            INTERVAL=600  # 10 minutes
            THRESHOLD=85
            AUTO=false
            shift
            ;;
        --aggressive)
            INTERVAL=120  # 2 minutes
            THRESHOLD=65
            AUTO=true
            shift
            ;;
        --monitor)
            INTERVAL=60   # 1 minute
            THRESHOLD=50
            AUTO=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Build the command
CMD="python3 $SCRIPT_DIR/memory_optimiser.py --interval $INTERVAL --threshold $THRESHOLD"
if [ "$AUTO" = true ]; then
    CMD="$CMD --auto"
fi
if [ "$TEST" = true ]; then
    CMD="$CMD --test"
fi

# Check if script exists
if [ ! -f "$SCRIPT_DIR/memory_optimiser.py" ]; then
    echo "Error: memory_optimiser.py not found in $SCRIPT_DIR."
    exit 1
fi

# Run the command
if [ "$BACKGROUND" = true ] && [ "$TEST" = false ]; then
    echo "Starting Memory Optimiser in background mode..."
    echo "Settings: Interval=$INTERVAL seconds, Threshold=$THRESHOLD%, Auto-optimise=$AUTO"
    echo "To stop: pkill -f memory_optimiser.py"
    nohup $CMD > /dev/null 2>&1 &
    echo "Memory Optimiser started with PID: $!"
else
    echo "Starting Memory Optimiser..."
    echo "Settings: Interval=$INTERVAL seconds, Threshold=$THRESHOLD%, Auto-optimise=$AUTO"
    if [ "$TEST" = false ]; then
        echo "Press Ctrl+C to stop"
    fi
    $CMD
fi