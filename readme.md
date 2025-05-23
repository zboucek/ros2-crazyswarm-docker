# ROS 2 Crazyswarm Docker

This repository is a fork of [captain-bender/ros2-crazyswarm-docker](https://github.com/captain-bender/ros2-crazyswarm-docker), updated to use ROS 2 Jammy and to support GUI applications (e.g., for simulation or swarm configuration).

## Using CLI
To build the image with Buildx, you need to type:
```bash
docker buildx build --no-cache -t ros2-crazyswarm .
```

To run the container with GUI support, you need to type:
```bash
docker run -it --rm --network=host --ipc=host \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v /run/user/$(id -u)/wayland-0:/run/user/$(id -u)/wayland-0 \
  -e DISPLAY=$DISPLAY \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  --name ros2-crazyswarm \
  ros2-crazyswarm
```

## Using Docker Compose
To start the Docker Compose setup, you need to type:
```bash
docker compose up -d
```

To access the container, you need to type:
```bash
docker exec -it ros2-crazyswarm /bin/bash
```

To stop the Docker Compose setup, you need to type:
```bash
docker compose down
```

## Running the Simulation Example
To run the simulation example, use the following command inside the container:
```bash
ros2 launch crazyflie_examples launch.py script:=hello_world backend:=sim
```

## Updates
- Added support for both Wayland and X11 display environments.
- Dynamically configured ROS distribution using the `${ROS_DISTRO}` variable.

## Notes
- Ensure that the `WAYLAND_DISPLAY` or `DISPLAY` environment variable is correctly set based on your display server.
- GUI applications can be accessed via a web browser at `http://127.0.0.1:8080/` during simulation.

## Level of Readiness
This setup has not been tested exhaustively. Use it at your own risk. If you discover issues, please report them.

## Environment
This setup was tested on an Ubuntu 24.04.1 LTS machine.

## Author
Originally created by Angelos Plastropoulos, with updates for ROS 2 Jazzy and GUI support by Zdeněk Bouček.

## References
- [Docker Buildx Documentation](https://docs.docker.com/build/)
- [Crazyswarm2 Documentation](https://imrclab.github.io/crazyswarm2/index.html)
- [Crazyswarm2 Repository](https://github.com/IMRCLab/crazyswarm2)