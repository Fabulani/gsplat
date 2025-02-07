# Docker README

Docker scripts based on [this PR](https://github.com/nerfstudio-project/gsplat/pull/303). Instead of Ubuntu 20.04 and CUDA 11.7, like in the PR, this fork uses Ubuntu 22.04 with latest PyTorch and CUDA 12.6, plus it pre-compiles wheels for dependencies that caused errors on Docker (i.e., `fused-ssim`).

- [Docker README](#docker-readme)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
  - [Build the images](#build-the-images)
  - [How-to Gaussian Splatting in gsplat](#how-to-gaussian-splatting-in-gsplat)
  - [Troubleshoot](#troubleshoot)

## Requirements

- Nvidia GPU: <https://docs.docker.com/engine/containers/resource_constraints/#gpu>
- Docker.

## Quickstart

> Assumes the image is already built or pulled from Github Container Registry. If not, go to [Build the images](#build-the-images).

Create a `.env` file in the project root:

```txt
# Inside .env
# Path to the dataset directory, e.g. C:/Users/username/Documents/datasets
HOST_DATA_PATH="your/path"

# gsplat version.
GSPLAT_VERSION="1.4.0"
```

Run with:

```sh
docker compose up -d
docker exec -it nerfstudio-gsplat-worker bash
```

Stop container with:

```sh
docker compose down
```

---

Alternatively, build and run the container with:

```sh
docker run --gpus all --name nerfstudio-gsplat-worker -it -v $HOST_DATA_PATH:/workspaces/gsplat/data nerfstudio-gsplat-worker:1.4.0
```

> Note! The `HOST_DATA_PATH` environment variable must be the path to your datasets folder.

## Build the images

There are two images:

- `nerfstudio-gsplat-base`: builder image for compiling CUDA scripts and generating the necessary `.whl` files for Python packages.
- `nerfstudio-gsplat-worker`: runtime image which will install the packages and run `gsplat`.

Build the images with:

```sh
./build_image.sh
```

## How-to Gaussian Splatting in gsplat

First, make sure your `./data` folder is structured correctly:

```txt
- data
-- dataset-name

--- images
---- img1.png
---- img2.png
---- ...

--- sparse
---- cameras.bin
---- images.bin
---- points3D.bin


-- other-dataset ...
```

Train a splat model with:

```sh
python3 examples/simple_trainer.py default --data_dir data/<your-data-folder> --data_factor 1 --result_dir results/<some-output-folder>
```

where:

- `--data_dir` is the path to the dataset you'd like to use. Specify the folder containing `images` and `sparse`.
- `--result_dir` is the path to the output folder, where gsplat will save checkpoints and other outputs. If you want results to be persistent, save them to the `data` folder, e.g., `data/results/<some-output-folder>`.
- `--data_factor` is for when the input images are downscaled (see MIP nerf dataset). For our datasets, we'll mostly only ever use `1`.

## Troubleshoot

- You can use `test_cuda.py` to check if PyTorch and CUDA are working.
- If `fused-ssim` fails to build wheels (on Windows), increase WSL memory to at least 6GB in `.wslconfig`.
