# ROS 2 Crazyswarm docker

This is an image that I generated using installation guide in [Crazyswarm official page](https://crazyswarm.readthedocs.io/en/latest/).


## Using CLI 
To build the image, you need to type:
```$
docker build --no-cache -t ros2-crazyswarm  .
```

To run the container, you need to type:
```$
docker run -it --rm --network=host --ipc=host -v /tmp/.X11-unix:/tmp/.X11-unix:rw --env=DISPLAY --name ros2-crazyswarm swarm -container ros2-crazyswarm 
```

## Using docker compose
To start the docker compose, you need to type:
```$
docker compose up -d
```
To get access in the container, you need to type:
```$
docker exec -it ros2-crazyswarm -container /bin/bash
```
To stop the docker compose, you need to type:
```$
docker compose down
```

## Levevl of readiness
Not tested exhaustively. Use it on your own risk. If you discover issues, please report them.

## Environment (or it works in my machine)
It was testes in an Ubuntu 24.04.1 LTS machine

### Author (to blame)
Angelos Plastropoulos