#!/bin/bash

echo "Building Ether...\n"

mkdir -p build
cd build

cmake ../diskimg
make

nasm ../bios/boot.asm -o boot.bin

./diskimg
