#!/bin/bash

echo -e "\e[1;32mEther Build Utility CI v1.0.0\e[0m"
echo ""

# Create build directory

mkdir -p build

# CMake

cd build
cmake .. -DCMAKE_BUILD_TYPE=Coverage
make
make ether_coverage
ctest
cd ..

# Assemble

nasm ./mbr/main.asm -o ./build/main.mbr