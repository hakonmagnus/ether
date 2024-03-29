//============================================================================|
//  _______ _________          _______  _______                               |
//  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                             |
//  | (    \/   ) (   | )   ( || (    \/| (    )|                             |
//  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.      |
//  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.      |
//  | (         | |   | (   ) || (      | (\ (                                |
//  | (____/\   | |   | )   ( || (____/\| ) \ \__                             |
//  (_______/   )_(   |/     \|(_______/|/   \__/                             |
//============================================================================|

#include "partlib/Image.hpp"

#include <iostream>
#include <ctime>
#include <cstdlib>

int main(int argc, char** argv)
{
    size_t size{ 0x10000000 };
    std::string output{ "./disk.img" };
    std::string mbr{ "./build/main.mbr" };
    std::string loader{ "./build/loader.bin" };
    std::string ebfs{ "./build/boot" };
    std::cout << "\033[1;34mEther Disk Utility v1.0.0\033[0m\n";
    srand(time(nullptr));
    
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];
        
        if (arg == "v" || arg == "--version")
            return 0;
        else if (arg == "-h" || arg == "--help")
        {
            std::cout << "Usage: diskutil\n"
                << "  (-v|--version) Show the current version of the utility\n"
                << "  (-h|--help) Show this message\n"
                << "  (-s|--size) Total size in sectors\n"
                << "  (-o|--output) Output filename\n"
                << "  (-m|--mbr) MBR filename\n"
                << "  (-l|--loader) Loader filename\n"
                << "\n";
            return 0;
        }
        else if (arg == "-s" || arg == "--size")
        {
            std::string sizestr = argv[++i];
            size = std::atoi(sizestr.c_str());
            size *= 0x200;
        }
        else if (arg == "-o" || arg == "--output")
        {
            output = argv[++i];
        }
        else if (arg == "-m" || arg == "--mbr")
        {
            mbr = argv[++i];
        }
        else if (arg == "-l" || arg == "--loader")
        {
            loader = argv[++i];
        }
        else
        {
            std::cout << "\033[1;31mUnsupported argument " << arg << "\033[0m\n";
            return 1;
        }
    }
    
    Image* image = new Image(size, mbr, loader, ebfs);
    
    if (!image->write(output))
    {
        std::cout << "\033[1;31mCould not write disk image.\033[0m\n";
        delete image;
        image = nullptr;
        return 1;
    }
    
    delete image;
    image = nullptr;
    
    std::cout << "\033[1;34mEther Disk Utility: Disk image created.\033[0m\n";
    return 0;
}
