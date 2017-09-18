#!/bin/bash

# initialize global variables
containerName=opencv3-cuda
containerTag=1.0
GREEN='\033[1;32m'
NC='\033[0m' # no color
user=`id -u -n`
userid=`id -u`
group=`id -g -n`
groupid=`id -g`

if [ $1 = "help" ];then
	echo -e "${GREEN}>>> Possible commands:\n ${NC}"
	echo -e "opencv [Version] --- Downloads specific OpenCV version from github repo to current dir\n"
	echo -e "build [Repository Name][Tag] --- Build an image based on DockerFile in current dir, and\nuses the provided name and tag\n"
	echo -e "create [Conatainer Name][Image Name] --- Instantiates a container based on the given image\n"
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
	/usr/local/bin/nvidia-docker build -t ${user}/${repoName}:${imageTag} .
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

	nvidia-docker create -it \
        $DRI_ARGS \
        --name="${containerName}" \
        --hostname="${user}-${space}" \
        --net=default \
	--publish 8888:8888 \
        --env="DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume=`pwd`/local:/home/local \
        ${imageName}
fi

if [ $1 = "start" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Starting container ${containerName} ...${NC}"
	nvidia-docker start $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "stop" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Stopping container ${containerName} ...${NC}"
	nvidia-docker stop $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "console" ]; then
	containerName=$2
	echo -e "${GREEN}>>> Entering console in container ${containerName} ...${NC}"
	nvidia-docker exec -ti ${containerName} /bin/bash 
fi
