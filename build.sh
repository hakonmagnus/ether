#!/bin/bash

echo "Building Ether...\n"

# Create and enter build directory
mkdir -p build
cd build

# Build the utils
cmake ../utils
make

# Exit gracefully
echo "Build succeeded."
exit 0
