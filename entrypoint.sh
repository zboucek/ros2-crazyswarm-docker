#!/bin/bash
set -e

# Setup the Demo environment
cd /home/ros2_ws/
# Use ${ROS_DISTRO} to dynamically source the correct ROS setup file
source /opt/ros/${ROS_DISTRO}/setup.bash

# Detect and configure display environment (Wayland or X11)
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "Using Wayland display: $WAYLAND_DISPLAY"
    export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
elif [ -n "$DISPLAY" ]; then
    echo "Using X11 display: $DISPLAY"
    export DISPLAY=$DISPLAY
else
    echo "No display environment detected."
fi

# Check if the environment variable RUN_MODE is set to "compose"
if [ "$RUN_MODE" = "compose" ]; then
    # Run sleep infinity if it's Docker Compose
    exec sleep infinity
else
    # Otherwise, run /bin/bash for CLI usage
    exec /bin/bash
fi

exec "$@"