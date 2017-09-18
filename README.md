# docker-opencv3-py3-cuda
Dockerfile and scripts to create a container with OpenCV 3.3 + CUDA enable + python 3

## NOTES:
This Dockerfile is meant to install OpenCV 3.3+Python3 with CUDA capabilities.

Ideally the Dockerfile should trigger the build and install process of OpenCV. 
However, nvida-drivers and CUDA toolkit must be detected at installation time; and this is not
possible if the container is not already running (or I have not found a way to do it yet). 

The nvidia-docker plugin loads the Nvidia devices and drivers from the host only when 
a container is instantiated (only with docker run and create, not docker build). 
For this reason, the Dockerfile just copies the script *make_opencv.sh* to the container directory and it
should be run inside the container once it is running.

If you want to download the docker images with OpenCV already installed, 
visit [this docker hub repo](https://hub.docker.com/r/arturokkboss33/opencv3-py3-cuda/tags/) (Version 1.2)

## *my_docker.sh* usage:

Executing **./my_docker help** will generate the following output:

*>>> Possible commands:*
 
*opencv [Version] --- Downloads specific OpenCV version from github repo to current dir*

*build [Repository Name][Tag] --- Build an image based on DockerFile in current dir, and
use the provided name and tag*

*start [Container Name] --- Starts an already instantiated container*

*stop [Container Name] --- Stops a running container*

*console [Container Name] --- Gives terminal access (/bin/bash) access to a running container*

## USeful commands:

* Inside the console of the container:
  * Execute *workon cv-py3* . This is the default virtual environment created to install OpenCV with Python3, it was done
  to keep a better maintenance or in case the user wants to make a similar installation with Python2.7.
  * Execute *runJupyterNotebook* (inside the virtual env). This starts a jupyter notebook in your browser, it is an alias made 
  to find automatically the container's IP and set it as a parameter for the the *jupyter* command. 

