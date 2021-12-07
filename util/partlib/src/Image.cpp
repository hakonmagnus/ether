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
#include "partlib/GPT.hpp"
#include "partlib/GUID.hpp"
#include "partlib/CRC32.hpp"

#include <cstring>
#include <fstream>
#include <iostream>

Image::Image(const size_t size, const std::string& mbr,
    const std::string& loader) :
    m_size{ size }, m_image{ nullptr }, m_mbr{ mbr },
    m_loader{ loader }
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
    size_t biosSize = 64;
    
    auto loaderfile = std::fstream(m_loader, std::ios::in | std::ios::binary | std::ios::ate);
    auto loadersize = loaderfile.tellg();
    loaderfile.seekg(0, std::ios::beg);
    loaderfile.read((char*)&m_image[0x200 * 35], loadersize);
    loaderfile.close();
    
    uint8_t* entries = new uint8_t[4 * sizeof(GPTEntry)];
    memset(entries, 0, 4 * sizeof(GPTEntry));
    
    GPTEntry bios;
    memset(&bios, 0, sizeof(bios));
    memcpy(bios.typeGUID, biosGUID, 16);
    generateGUID(bios.uniqueGUID);
    bios.firstLBA = 35;
    bios.lastLBA = 35 + biosSize;
    memcpy(bios.partitionName, u"BIOS boot partition", 19 * sizeof(char16_t));
    memcpy(&entries[0], &bios, sizeof(bios));
    
    memcpy(&m_image[0x400], entries, 4 * sizeof(GPTEntry));
    memcpy(&m_image[((m_size / 0x200) - 34) * 0x200], entries, 4 * sizeof(GPTEntry));
    
    GPTHeader gpt;
    memset(&gpt, 0, sizeof(gpt));
    memcpy(gpt.signature, "EFI PART", 8);
    gpt.revision = 0x00010000;
    gpt.headerSize = 0x5C;
    gpt.headerCRC32 = 0;
    gpt.currentLBA = 1;
    gpt.backupLBA = (m_size / 0x200) - 1;
    gpt.firstUsableLBA = 34;
    gpt.lastUsableLBA = (m_size / 0x200) - 35;
    generateGUID(gpt.diskGUID);
    gpt.entriesLBA = 2;
    gpt.numEntries = 4;
    gpt.entrySize = 0x80;
    gpt.entriesCRC32 = crc32(0, entries, 4 * sizeof(GPTEntry));
    gpt.headerCRC32 = crc32(0, &gpt, sizeof(gpt));
    memcpy(&m_image[0x200], &gpt, sizeof(gpt));
    
    gpt.currentLBA = (m_size / 0x200) - 1;
    gpt.backupLBA = 1;
    gpt.entriesLBA = (m_size / 0x200) - 34;
    gpt.headerCRC32 = 0;
    gpt.headerCRC32 = crc32(0, entries, 4 * sizeof(GPTEntry));
    memcpy(&m_image[((m_size / 0x200) - 1) * 0x200], &gpt, sizeof(gpt));
    
    delete entries;
    entries = nullptr;
    
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