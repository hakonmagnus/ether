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

mkdir -p ./build/boot
mkdir -p ./build/boot/module

echo -e "\e[1;32mAssembling boot sectors...\e[0m"

nasm ./mbr/main.asm -o ./build/main.mbr
nasm ./loader/loader.asm -o ./build/loader.bin
nasm ./efi/efi.asm -o ./build/BOOTX64.EFI

# Kernel

echo -e "\e[1;32mAssembling and linking kernel...\e[0m"

mkdir -p ./build/ether
mkdir -p ./build/ether/lib
mkdir -p ./build/ether/cpu
mkdir -p ./build/ether/video
nasm -felf64 ./ether/entry.asm -o ./build/ether/entry.o
nasm -felf64 ./ether/multiboot.asm -o ./build/ether/multiboot.o
nasm -felf64 ./ether/main.asm -o ./build/ether/main.o
nasm -felf64 ./ether/lib/string.asm -o ./build/ether/lib/string.o
nasm -felf64 ./ether/cpu/gdt.asm -o ./build/ether/cpu/gdt.o
nasm -felf64 ./ether/cpu/sse.asm -o ./build/ether/cpu/sse.o
nasm -felf64 ./ether/video/vgatext.asm -o ./build/ether/video/vgatext.o
ld -T ./ether/link.ld -o ./build/boot/ether ./build/ether/entry.o ./build/ether/multiboot.o ./build/ether/cpu/gdt.o \
    ./build/ether/main.o ./build/ether/lib/string.o ./build/ether/video/vgatext.o ./build/ether/cpu/sse.o

# Config

cp ./config/boot.config ./build/boot/boot.config

# Create disk image

dd if=/dev/zero of=./build/esp.img count=2 bs=1M
mkfs.vfat ./build/esp.img

./build/util/diskimg/diskimg

echo -e "\e[1;32mDone!\e[0m"
