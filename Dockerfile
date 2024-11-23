ARG ROS_DISTRO=humble
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

# Set up colcon_cd for future bash sessions
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Add Gazebo repository
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Set up the gazebo version
ARG GZ_VERSION=fortress

# Install Gazebo
RUN apt-get update \
  && apt-get install -y \
  gz-${GZ_VERSION} \
  ros-${ROS_DISTRO}-ros-gz-sim \
  ros-${ROS_DISTRO}-ros-gz-bridge \
  && rm -rf /var/lib/apt/lists/*

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

# Install Python packages dependencies
RUN pip3 install rowan nicegui
RUN pip3 install cflib transform3D

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

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Interactive bash shell
CMD ["/bin/bash"]
# CMD ["sleep", "infinity"]