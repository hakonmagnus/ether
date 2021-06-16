#ifndef _DISK_H
#define _DISK_H

#include <string>

class Disk {
public:
    Disk(size_t bootSize, size_t efiSize, size_t mainSize, std::string mbrName);
    ~Disk();

    void render();
    void write(std::string filename);

private:
    unsigned char* m_buffer;
    size_t m_bootSize;
    size_t m_efiSize;
    size_t m_mainSize;
    std::string m_mbrName;
};

#endif
