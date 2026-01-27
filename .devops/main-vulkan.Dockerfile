ARG UBUNTU_VERSION=26.04

FROM ubuntu:$UBUNTU_VERSION AS build
WORKDIR /app


RUN apt-get update && \
    apt-get install -y git build-essential cmake wget xz-utils \
    libssl-dev curl libxcb-xinput0 libxcb-xinerama0 libxcb-cursor-dev libvulkan-dev glslc

COPY . .

RUN cmake -B build -DGGML_NATIVE=OFF -DGGML_VULKAN=ON -DGGML_BACKEND_DL=ON -DGGML_CPU_ALL_VARIANTS=ON && \
    cmake --build build --config Release -j$(nproc)

RUN find build -name "*.so*" -exec cp -P {} /app \;

FROM ubuntu:$UBUNTU_VERSION AS runtime
WORKDIR /app

RUN apt-get update \
    && apt-get install -y libgomp1 curl libvulkan1 mesa-vulkan-drivers \
    libglvnd0 libgl1 libglx0 libegl1 libgles2

COPY --from=build /app /app

ENV PATH=/app/build/bin:$PATH
ENTRYPOINT [ "bash", "-c" ]
