#!/bin/bash

GREEN='\033[1;32m'
NC='\033[0m' # no color
virtualEnvName=cv-py3
nproc=4
user=`id -u -n`

#create virtual environment to ensure use of python 3 bindings (this can be done also for pyhton2)
echo -e "\n${GREEN}>>> Creating Pyhton 3 virtual environment${NC}"
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv $virtualEnvName -p python3
workon $virtualEnvName

#install python dependencies for development
echo -e "\n${GREEN}>>> Install python scientific libraries${NC}"
pip install numpy scipy matplotlib scikit-image scikit-learn jupyter notebook pandas

#create a build dir for OpenCV and build it
echo -e "\n${GREEN}>>> Configuring CMake files for OpenCV${NC}"
cd /home/${user}/opencv-3.3.0/ && mkdir build && cd build 
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_opencv_java=OFF -D INSTALL_C_EXAMPLES=OFF -D OPENCV_EXTRA_MODULES_PATH=/home/${user}/opencv_contrib-3.3.0/modules -D BUILD_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D PYTHON_EXECUTABLE=/home/${user}/.virtualenvs/$virtualEnvName/bin/python -D WITH_CUDA=ON -D WITH_CUBLAS=ON -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CUDA_CUDA_LIBRARY=/usr/local/nvidia/lib64/libcuda.so -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 -D CUDA_CUDART_LIBRARY=/usr/local/cuda-8.0/targets/x86_64-linux/lib/libcudart.so -D CUDA_NVCC_FLAGS="-D_FORCE_INLINES" -D CUDA_GENERATION=Auto -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_NVCUVID=OFF -D WITH_CUFFT=ON -D WITH_EIGEN=ON -D WITH_IPP=ON -D INSTALL_C_EXAMPLES=ON ..
echo -e "\n${GREEN}>>>Building and installing OpenCV${NC}"
make -j$nproc
make install
ldconfig

#link opencv libraries
echo -e "\n${GREEN}>>> Linking python libraries of the virtual environment${NC}"
cd /usr/local/lib/python3.5/site-packages/ && mv cv2.* cv2.so
cd /home/${user}/.virtualenvs/$virtualEnvName/lib/python3.5/site-packages/ && ln -s /usr/local/lib/python3.5/site-packages/cv2.so cv2.so

echo -e "\n${GREEN}>>> Fixing CUDART library link${NC}"
#link cuda runtime library (necessary in docker)
ln -s /usr/local/cuda-8.0/targets/x86_64-linux/lib/libcudart.so /usr/lib/libcudart.so

deactivate
echo -e "\n${GREEN}>>> Finish installing OpenCV in virtual enviroment ${virtualEnvName} ${NC}"


