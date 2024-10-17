FROM arm64v8/ubuntu:20.04

# Оновлюємо пакети і встановлюємо всі необхідні залежності
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    nano \
    net-tools \
    netcat \
    python3-pip \
    ninja-build \
    build-essential \
    pkg-config \
    libboost-dev \
    libjpeg-dev \
    libtiff5-dev \
    libudev-dev \
    libdrm-dev \
    libexpat1-dev \
    libx11-dev \
    libgles2-mesa-dev \
    libgnutls28-dev \
    libpng-dev \
    libglib2.0-dev \
    cmake \
    libssl-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    doxygen \
    graphviz \
    gcc \
    python3-dev \
    libxml2-dev \
    libxslt-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Встановлюємо Python-пакети
RUN pip3 install --upgrade meson numpy future lxml pymavlink jinja2 pyyaml ply signalr-client-aio aiortc websockets

# Клонуємо та збираємо OpenCV та OpenCV contrib
RUN git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv && \
    git submodule update --recursive --init && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D INSTALL_C_EXAMPLES=OFF \
          -D PYTHON_EXECUTABLE=$(which python3) \
          -D BUILD_opencv_python2=OFF \
          -D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
          -D PYTHON3_EXECUTABLE=$(which python3) \
          -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
          -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
          -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
          -D WITH_GSTREAMER=ON \
          -D BUILD_EXAMPLES=ON .. && \
    make -j$(($(nproc) / 2)) && \
    make install && \
    ldconfig

# Клонуємо та збираємо libcamera
RUN git clone https://git.libcamera.org/libcamera/libcamera.git && \
    cd libcamera && \
    meson setup build && \
    ninja -C build && \
    ninja -C build install && \
    ldconfig
