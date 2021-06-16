#include "Disk.h"
#include <iostream>
#include <cstring>

void print_help() {
    std::cout << "Usage: diskimg\t[-h|--help] [--bootsize=<Boot partition size in MB>]" << std::endl;
    std::cout << "\t\t[--efisize=<EFI partition size in MB>]" << std::endl;
    std::cout << "\t\t[--mainsize=<Main partition size in MB>]" << std::endl;
    std::cout << "\t\t[-o=<Output filename>]" << std::endl;
    std::cout << "\t\t[--mbrname=<MBR filename>]" << std::endl;
}

int main(int argc, char** argv) {
    std::cout << "EtherOS Disk Utility v1.0.0" << std::endl << std::endl;

    size_t main_size = 64;
    size_t efi_size = 32;
    size_t boot_size = 32;
    std::string output = "disk.img";
    std::string mbrName = "boot.bin";

    if (argc > 1) {
        for (int i = 1; i < argc; ++i) {
            if (strcmp(argv[i], "-h")==0 || strcmp(argv[i], "--help")==0) {
                print_help();
                return 0;
            } else {
                print_help();
                return 1;
            }
        }
    }

    Disk* disk = new Disk(boot_size, efi_size, main_size, mbrName);

    disk->render();
    disk->write(output);

    delete disk;

    std::cout << "Disk image generated" << std::endl;

    return 0;
}
