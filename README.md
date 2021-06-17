# Ether Operating System

[![Build Status](https://travis-ci.com/hakonmagnus/ether.svg?branch=main)](https://travis-ci.com/hakonmagnus/ether)
[![codecov](https://codecov.io/gh/hakonmagnus/ether/branch/master/graph/badge.svg?token=7CS3A5V6B0)](https://codecov.io/gh/hakonmagnus/ether)

The Ether Operating System is a POSIX operating system for the x86
architecture written in assembly language. It is built with optimization
in mind, with high performance and low disk space requirements. It makes
use of new technology such as UEFI and Intel instructions.

## Build

To build Ether, you need to have a UNIX terminal to run build.sh in the
root directory. You must also have NASM installed.

```
sudo chmod +x build.sh
./build.sh
```

This creates a *build* directory which contains the disk image.

## Running the image

The raw image file (disk.img by default) can be run by any virtual machine.
If you need to, you can convert the raw image to a suitable format for
your virtual machine.

## Installer ISO

Currently, there is no installer. One will be made shortly.

## Documentation

Please look at the [docs](/docs) directory for some useful documentation files.

## Contribute

See [CONTRIBUTING.md](/CONTRIBUTING.md)

## License

This project is licensed under the [MIT License](/LICENSE).
