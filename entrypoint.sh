#!/bin/bash
set -e

# Setup the Demo environment
cd /home/ros2_ws/
source /opt/ros/humble/setup.bash

# Check if the environment variable RUN_MODE is set to "compose"
if [ "$RUN_MODE" = "compose" ]; then
    # Run sleep infinity if it's Docker Compose
    exec sleep infinity
else
    # Otherwise, run /bin/bash for CLI usage
    exec /bin/bash
fi

exec "$@"