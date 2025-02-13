FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    python-is-python3 \
    python3-dev \
    python3-pip \ 
    libglm-dev \
    git


# CUDA Toolkit required for gsplat due to nvcc dependency:
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get -y install cuda-toolkit-12-6 \
    && rm cuda-keyring_1.1-1_all.deb

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# PyTorch
RUN pip3 install --no-cache-dir --upgrade pip setuptools && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

RUN git clone https://github.com/rahul-goel/fused-ssim.git && \
    cd fused-ssim && \
    git checkout 1272e21a282342e89537159e4bad508b19b34157
