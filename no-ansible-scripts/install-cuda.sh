#!/bin/bash

set -e

# Variables
NVIDIA_REPO_URL="https://nvidia.github.io/nvidia-docker"
CUDA_RUNTIME_IMAGE="nvidia/cuda:12.2.0-runtime-ubuntu22.04"

# Update and install packages
echo "Installing NVIDIA drivers and CUDA toolkit..."
apt update
apt install -y nvidia-driver-535 nvidia-cuda-toolkit clinfo linux-modules-nvidia-535-generic-hwe-22.04

# Add NVIDIA Docker GPG key
echo "Adding NVIDIA Docker GPG key..."
curl -s -L "${NVIDIA_REPO_URL}/gpgkey" | apt-key add -

# Add NVIDIA Docker repository
echo "Adding NVIDIA Docker repository..."
distribution=$(. /etc/os-release; echo "${ID}${VERSION_ID}")
curl -s -L "${NVIDIA_REPO_URL}/${distribution}/nvidia-docker.list" | tee /etc/apt/sources.list.d/nvidia-docker.list

# Update APT cache and install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
apt update
apt install -y nvidia-container-toolkit

# Verify NVIDIA CUDA runtime with Docker
echo "Verifying NVIDIA CUDA runtime with Docker..."
if ! docker run --gpus all --rm "$CUDA_RUNTIME_IMAGE" nvidia-smi; then
  echo "Failed to verify NVIDIA CUDA runtime with Docker"
  exit 1
fi

echo "Setup completed successfully!"

