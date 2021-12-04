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

echo -e "\e[1;32mDone!\e[0m"