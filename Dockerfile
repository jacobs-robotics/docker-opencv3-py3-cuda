#base image
FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER arturokkboss33 "a.gomezchavez@jacobs-university.de"

#update system repos and libraries
RUN apt-get update -y && apt-get upgrade -y
#essential extra packages
RUN apt-get install -y wget unzip vim git cmake

#opencv dependencies 1
RUN apt-get install -y libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev libavcodec-dev \
    libavformat-dev libswscale-dev libv4l-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran
#opencv dependencies 2
RUN apt-get install -y libopencv-dev checkinstall yasm libdc1394-22-dev libxine2-dev \
    libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libtbb-dev libqt4-dev libfaac-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev \
    v4l-utils ffmpeg qt5-default libhdf5-dev

#install python packages and virtual env. packages
RUN apt-get install -y python3 python-dev python3-dev python3-pip
RUN cd /home && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py 
RUN pip install virtualenv virtualenvwrapper && pip3 install virtualenv virtualenvwrapper
RUN /bin/bash -c "echo   >> /root/.bashrc" && /bin/bash -c "echo # virtualenv and virtualenvwrapper >> /root/.bashrc" && \
    /bin/bash -c "echo export WORKON_HOME=$HOME/.virtualenvs >> /root/.bashrc" && \
    /bin/bash -c "echo source /usr/local/bin/virtualenvwrapper.sh >> /root/.bashrc" && \
    /bin/bash -c ". /root/.bashrc"

#download opencv from repos
RUN cd /home && wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.3.0.zip && unzip opencv.zip
RUN cd /home && wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.3.0.zip && unzip opencv_contrib.zip

#copy script to install OpenCV in a virtual environment
COPY make_opencv.sh /home/.
RUN chmod a+x /home/make_opencv.sh 
COPY setup_bashrc.sh /home/.
RUN /bin/bash -c ". /home/setup_bashrc.sh"

#install network related packages to debug connectivity
#Decided to add at the end of the Dockerfile since they are not indispensable
RUN apt-get install -y net-tools iputils-ping
