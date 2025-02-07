#!/usr/bin/env bash
# CUDA Arch to build for (currently not used). Find yours here: https://developer.nvidia.com/cuda-gpus. E.g., `"7.5"`.
# export TORCH_CUDA_ARCH_LIST="7.5"
export GSPLAT_VERSION=`cat gsplat/version.py | cut -d '"' -f 2`

echo "build gsplat base image"
docker build \
    -t nerfstudio-gsplat-base:"${GSPLAT_VERSION}" \
    -f ./docker/gsplat_base.dockerfile .

echo "build gsplat and dependencies wheel"
# Create a container to build wheels since only the container can use CUDA
# Note: fused-ssim is a dependency of gsplat/examples that also requires cuda compilation. Its wheels are compiled and then moved to /gsplat/dist for easy installation in the next step.
docker run -t --rm --name nerfstudio-gsplat-wheel \
    --gpus 1 \
    -v $PWD:/gsplat \
    nerfstudio-gsplat-base:"${GSPLAT_VERSION}" \
    bash -c "cd /gsplat && python3 setup.py sdist bdist_wheel && cd /fused-ssim && python3 setup.py sdist bdist_wheel && mv /fused-ssim/dist/* /gsplat/dist/"

echo "build gsplat worker image"
docker build \
    --build-arg BASE_IMAGE=nerfstudio-gsplat-base:"${GSPLAT_VERSION}" \
    --build-arg GSPLAT_VERSION="${GSPLAT_VERSION}" \
    -t nerfstudio-gsplat-worker:"${GSPLAT_VERSION}" \
    -f ./docker/gsplat_worker.dockerfile .