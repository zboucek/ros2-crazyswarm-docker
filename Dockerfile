ARG ROS_DISTRO=jazzy
FROM osrf/ros:${ROS_DISTRO}-desktop

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Declare an ARG for setting RUN_MODE at build time (optional)
ARG RUN_MODE=cli

# Set an ENV variable based on the ARG (to make it available at runtime)
ENV RUN_MODE=${RUN_MODE}

# Ignore setup.py warnings in building phase
ENV PYTHONWARNINGS="ignore:setup.py install is deprecated::setuptools.command.install"

# Install required apps
RUN apt-get update \
  && apt-get install -y \
  nano \
  git \
  python3-pip \
  && rm -rf /var/lib/apt/list/*

# Install gazebo dependencies
RUN apt-get update \
  && apt-get install -y \
  curl \
  lsb-release \
  gnupg \
  python3-colcon-common-extensions \
  && rm -rf /var/lib/apt/list/*

# Install python3-venv for creating virtual environments
RUN apt-get update \
  && apt-get install -y python3-venv \
  && rm -rf /var/lib/apt/lists/*

# Set up colcon_cd for future bash sessions
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "export _colcon_cd_root=/opt/ros/${ROS_DISTRO}/" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Set up the environment
ENV GZ_RESOURCE_PATH=/usr/share/gazebo-${GZ_VERSION}

# Install crazyswarm2 dependencies
RUN apt-get update \
  && apt-get install -y \
  libboost-program-options-dev \
  libusb-1.0-0-dev \
  ros-${ROS_DISTRO}-motion-capture-tracking \
  ros-${ROS_DISTRO}-tf-transformations \
  ros-${ROS_DISTRO}-teleop-twist-keyboard \
  && rm -rf /var/lib/apt/lists/*

# Create and use a Python virtual environment for package installation
RUN python3 -m venv /opt/venv \
  && . /opt/venv/bin/activate \
  && pip install --upgrade pip \
  && pip install rowan nicegui cflib transforms3d empy catkin_pkg lark \
  && deactivate

# Set the virtual environment as the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# Set the working directory inside the container
WORKDIR /home

# Create the necessary workspace
RUN mkdir -p ros2_ws/src 

# Set the workingspace inside the container
WORKDIR /home/ros2_ws

# Clone the repositorys into ros2 workspace
RUN git clone https://github.com/IMRCLab/crazyswarm2 --recursive

# Set the working directory inside the container
# WORKDIR /home/ros2_ws/src

# Change permissions
RUN sudo chmod 777 -R /home/ros2_ws

# Set working directory to ros2_ws and build using colcon
WORKDIR /home/ros2_ws

# Build
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
  && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# Source ROS 2 workspace setup
RUN echo "source /home/ros2_ws/install/setup.bash" >> ~/.bashrc 

# Set the working directory inside the container
WORKDIR /home

# Clone the repositorys for the SITL simulation
RUN git clone --recursive https://github.com/bitcraze/crazyflie-firmware.git

# Build python bindings & dependencies
WORKDIR /home/crazyflie-firmware

RUN apt-get update \
  && apt-get install -y \
  swig \
  && rm -rf /var/lib/apt/lists/*

RUN make cf2_defconfig \
  && make bindings_python \
  && cd build \
  && python3 setup.py install --user

# Set PYTHONPATH environment variable
ENV PYTHONPATH=${PYTHONPATH:-}/home/crazyflie-firmware/build:$PYTHONPATH

# Set working directory to ros2_ws
WORKDIR /home/ros2_ws

# Add support for GUI applications
RUN apt-get update \
  && apt-get install -y \
  x11-apps \
  libgl1 \
  libxrender1 \
  libxext6 \
  && rm -rf /var/lib/apt/lists/*

# Set DISPLAY environment variable for GUI support
ENV DISPLAY=:0

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Interactive bash shell
CMD ["/bin/bash"]
# CMD ["sleep", "infinity"]