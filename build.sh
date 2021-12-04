#!/bin/bash

echo -e "\e[1;32mEther Build Utility CI v1.0.0\e[0m"
echo ""

# Create build directory

mkdir -p build

# CMake

cd build
cmake ..
make
cd ..

# Assemble

echo -e "\e[1;32mAssembling boot sectors...\e[0m"

nasm ./mbr/main.asm -o ./build/main.mbr

# Create disk image

dd if=/dev/zero of=./build/esp.img count=2 bs=1M
mkfs.vfat ./build/esp.img

./build/util/diskimg/diskimg

echo -e "\e[1;32mDone!\e[0m"