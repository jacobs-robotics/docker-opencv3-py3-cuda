#!/bin/bash

# initialize global variables
containerName=opencv3-py3-cuda
containerTag=1.0
GREEN='\033[1;32m'
BLUE='\e[34m'
NC='\033[0m' # no color
user=`id -u -n`
userid=`id -u`
group=`id -g -n`
groupid=`id -g`
myhostname=docker-opencv

if [ $1 = "help" ];then
	echo -e "${GREEN}>>> Possible commands:\n ${NC}"
	echo -e "${BLUE}opencv [Version] --- Downloads specific OpenCV version from github repo to current dir${NC}\n"
	echo -e "${BLUE}build [Repository Name][Tag] --- Build an image based on DockerFile in current dir, and\nuse the provided name and tag${NC}\n"
	echo -e "${BLUE}create [Container Name][Image Name] --- Create container from image${NC}\n"
	echo -e "${BLUE}start [Container Name] --- Starts an already instantiated container${NC}\n"
	echo -e "${BLUE}stop [Container Name] --- Stops a running container${NC}\n"
	echo -e "${BLUE}console [Container Name] --- Gives terminal access (/bin/bash) access to a running container${NC}\n"
fi

if [ "$1" = "opencv" ]; then
	echo -e "${GREEN}>>> Getting OpenCV 3.3 from github...${NC}"
	opencvVersion=$2
	cd `pwd` && /usr/bin/wget -O opencv.zip https://github.com/Itseez/opencv/archive/$opencvVersion.zip && unzip opencv.zip
	/usr/bin/wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/$opencvVersion.zip && unzip opencv_contrib.zip

fi

if [ "$1" = "build" ]; then
	repoName=$2
	imageTag=$3
	echo -e "${GREEN}>>> Building ${repoName}:${imageTag} image ...${NC}"
	docker build --build-arg user=$user \
	--build-arg userid=$userid \
	--build-arg group=$group \
	--build-arg groupid=$groupid \
	-t ${user}/${repoName}:${imageTag} .
fi

if [ "$1" = "create" ]; then
	
	containerName=$2
	imageName=$3

	echo -e "${GREEN}>>> Creating container ${containerName} from image ${imageName}...${NC}"
	
	if [ -d /dev/dri ]; then

        	DRI_ARGS=""
        	for f in `ls /dev/dri/*`; do
            		DRI_ARGS="$DRI_ARGS --device=$f"
        	done

        	DRI_ARGS="$DRI_ARGS --privileged"
    	fi

	#publish maps ports between the container and the host. Jupyter notebooks use port 8888 by default
	docker run --runtime=nvidia -it \
        $DRI_ARGS \
        --user="${userid}" \
	--name="${containerName}" \
        --hostname="${myhostname}" \
        --net=default \
	--publish 8888:8888 \
        --env="DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
	--workdir="/home/${user}" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume=`pwd`/workspace:/home/${user}/workspace \
        ${imageName}
fi

if [ $1 = "start" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Starting container ${containerName} ...${NC}"
	docker start --runtime=nvidia $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "stop" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Stopping container ${containerName} ...${NC}"
	docker stop $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "console" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Entering console in container ${containerName} ...${NC}"
	docker exec -ti ${containerName} /bin/bash 
fi
