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

#pragma once

#include <string>
#include <cstdint>

using std::size_t;

/**
 * \defgroup partlib Partition library
 * @{
 */

/**
 * Disk image class
 */
class Image
{
public:
    /**
     * Constructor
     * \param size Size of disk image
     * \param mbr MBR filename
     * \param loader Loader filename
     * \param ebfs EBFS root path
     */
    Image(const size_t size, const std::string& mbr, const std::string& loader,
            const std::string& ebfs);
    
    /**
     * Destructor
     */
    ~Image();
    
    /**
     * Write disk image
     * \param path Output filename
     * \return True on success
     */
    bool write(const std::string& path);
    
private:
    /**
     * Image buffer
     */
    uint8_t* m_image;
    
    /**
     * Size
     */
    size_t m_size;
    
    /**
     * MBR filename
     */
    std::string m_mbr;
    
    /**
     * Loader filename
     */
    std::string m_loader;

    /**
     * EBFS root
     */
    std::string m_ebfs;
};

/**
 * @}
 */
