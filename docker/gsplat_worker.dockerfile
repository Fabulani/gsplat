FROM ubuntu:22.04

WORKDIR /workspaces/gsplat

# Required for install of packages from examples/requirements.txt.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    git \
    gcc \
    wget \
    # Required for running simple_trainer.py
    libgl1 \
    libglib2.0-0 \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists

# PyTorch
RUN pip3 install --no-cache-dir --upgrade pip setuptools && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Download AlexNet checkpoint
RUN mkdir -p /root/.cache/torch/hub/checkpoints && \
    wget -O /root/.cache/torch/hub/checkpoints/alexnet-owt-7be5be79.pth \
    https://download.pytorch.org/models/alexnet-owt-7be5be79.pth

# GSPLAT_VERSION is an env variable passed as a `--build-arg` to the `docker build` command
ARG GSPLAT_VERSION

ARG GSPLAT_WHEEL=gsplat-${GSPLAT_VERSION}-cp310-cp310-linux_x86_64.whl
ARG FUSED_SSIM_WHEEL=fused_ssim-0.0.0-cp310-cp310-linux_x86_64.whl

COPY dist/${GSPLAT_WHEEL} .
COPY dist/${FUSED_SSIM_WHEEL} .
COPY examples/requirements.txt examples/requirements.txt

# Install Python packages
RUN pip3 install --no-cache-dir ${GSPLAT_WHEEL} && \
    pip3 install --no-cache-dir ${FUSED_SSIM_WHEEL} && \
    rm ${GSPLAT_WHEEL} && rm ${FUSED_SSIM_WHEEL} && \
    pip3 install --no-cache-dir -r examples/requirements.txt

COPY . .