#base image
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

MAINTAINER Arturo Gomez Chavez "a.gomezchavez@jacobs-university.de"

ARG user
ARG userid
ARG group
ARG groupid

#update system repos and libraries
RUN apt-get update -y && apt-get upgrade -y
#essential extra packages
RUN apt-get install -y wget unzip vim git cmake sudo

#opencv dependencies 1
RUN apt-get install -y libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev libavcodec-dev \
    libavformat-dev libswscale-dev libv4l-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran
#opencv dependencies 2
RUN apt-get install -y libopencv-dev checkinstall yasm libdc1394-22-dev libxine2-dev \
    libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libtbb-dev libqt4-dev libfaac-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev \
    v4l-utils ffmpeg qt5-default libhdf5-dev

# set up users and groups
RUN addgroup --gid $groupid $group && \
	adduser --uid $userid --gid $groupid --shell /bin/bash $user && \
	echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$user && \
	chmod 0440 /etc/sudoers.d/$user
# create initial workspace
RUN mkdir -p /home/$user/workspace

WORKDIR /home/$user
#install python packages and virtual env. packages
RUN apt-get install -y python3 python-dev python3-dev python3-pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py 
RUN pip install virtualenv virtualenvwrapper && pip3 install virtualenv virtualenvwrapper
RUN /bin/bash -c "echo   >> ./.bashrc" && /bin/bash -c "echo # virtualenv and virtualenvwrapper >> ./.bashrc" && \
    /bin/bash -c "echo export WORKON_HOME=$HOME/.virtualenvs >> ./.bashrc" && \
    /bin/bash -c "echo source /usr/local/bin/virtualenvwrapper.sh >> ./.bashrc" && \
    /bin/bash -c ". ./.bashrc"


#download opencv from repos
RUN wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.3.0.zip && unzip opencv.zip
RUN wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.3.0.zip && unzip opencv_contrib.zip

#copy script to install OpenCV in a virtual environment
COPY make_opencv.sh .
RUN chmod a+x make_opencv.sh 

#install network related packages to debug connectivity
#Decided to add at the end of the Dockerfile since they are not indispensable
RUN apt-get install -y net-tools iputils-ping
RUN /bin/bash -c "echo   >> ./.bashrc" && \
#    /bin/bash -c "echo alias showIP=' ifconfig eth0 | sed -n "2s/[^:]*:\([^ ]*\).*/\1/p" ' >> ./.bashrc" && \
    /bin/bash -c "echo alias runJupyterNotebook='jupyter notebook --allow-root --ip=172.17.0.2 --port=8888' " && \
    /bin/bash -c ". ./.bashrc"
