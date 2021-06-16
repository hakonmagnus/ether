#include "Disk.h"
#include <fstream>
#include <cstring>
#include <iostream>

Disk::Disk(size_t bootSize, size_t efiSize, size_t mainSize, std::string mbrName) :
    m_bootSize(bootSize), m_efiSize(efiSize), m_mainSize(mainSize), m_mbrName(mbrName) {
    size_t totalSize = (bootSize + efiSize + mainSize) * 1024 * 1024;
    m_buffer = new unsigned char[totalSize];
    memset(m_buffer, 0, totalSize);
}

Disk::~Disk() {
}

void Disk::render() {
    unsigned char* mbr = new unsigned char[0x200];

    std::ifstream mbrFile(m_mbrName, std::ios::in | std::ios::binary);
    mbrFile.seekg(0, std::ios::end);
    size_t mbrSize = mbrFile.tellg();

    if (mbrSize != 0x200) {
        std::cout << "Invalid MBR size." << std::endl;
        throw;
    }

    mbrFile.seekg(0, std::ios::beg);

    mbrFile.read((char*)mbr, 0x200);

    memcpy(m_buffer, mbr, 0x200);
}

void Disk::write(std::string filename) {
    size_t totalSize = (m_bootSize + m_efiSize + m_mainSize) * 1024 * 1024;
    std::ofstream file(filename, std::ios::out | std::ios::binary);
    file.write(reinterpret_cast<const char*>(m_buffer), totalSize);
    file.close();
}
