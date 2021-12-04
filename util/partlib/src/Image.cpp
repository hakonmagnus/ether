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

#include <cstring>
#include <fstream>
#include <iostream>

Image::Image(const size_t size, const std::string& mbr) :
    m_size{ size }, m_image{ nullptr }, m_mbr{ mbr }
{
    m_image = new uint8_t[size];
    memset(m_image, 0, size);
}

Image::~Image()
{
    delete m_image;
    m_image = nullptr;
}

bool Image::write(const std::string& output)
{
    auto mbrfile = std::fstream(m_mbr, std::ios::in | std::ios::binary | std::ios::ate);
    
    if (mbrfile.tellg() != 512)
    {
        std::cout << "\033[1;31mEther Disk Utility: MBR image must be exactly 512 bytes.\033[0m\n";
        mbrfile.close();
        return false;
    }
    
    mbrfile.seekg(0, std::ios::beg);
    mbrfile.read((char*)m_image, 512);
    mbrfile.close();
    
    auto file = std::fstream(output, std::ios::out | std::ios::binary);
    file.write((char*)m_image, m_size);
    file.close();
    return true;
}