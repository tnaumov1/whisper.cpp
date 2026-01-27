ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION AS build
WORKDIR /app


RUN apt-get update && \
    apt-get install -y build-essential libsdl2-dev wget cmake git \
    libssl-dev libxcb-xinput0 libxcb-xinerama0 libxcb-cursor-dev \
    libvulkan-dev glslc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY .. .

RUN make base.en CMAKE_ARGS="-DGGML_VULKAN=1"

RUN find /app/build -name "*.o" -delete && \
    find /app/build -name "*.a" -delete && \
    rm -rf /app/build/CMakeFiles && \
    rm -rf /app/build/cmake_install.cmake && \
    rm -rf /app/build/_deps

FROM ubuntu:$UBUNTU_VERSION AS runtime
WORKDIR /app

RUN apt-get update \
    && apt-get install -y libgomp1 libvulkan1 mesa-vulkan-drivers \
    libglvnd0 libgl1 libglx0 libegl1 libgles2 curl ffmpeg wget

COPY .. /app

ENV PATH=/app/build/bin:$PATH
ENTRYPOINT [ "bash", "-c" ]
