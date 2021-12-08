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
#include <vector>
#include <cstdint>

using std::size_t;

/**
 * \addtogroup partlib
 * @{
 */

/**
 * Directory info
 */
struct EBFSDirectoryInfo
{
    std::string name;           ///< Name of entry
    std::string path;           ///< Path of entry
    bool isDir;                 ///< True if directory
    bool isRoot;                ///< True if root directory
    std::vector<EBFSDirectoryInfo*> children;   ///< Child entries
    EBFSDirectoryInfo* parent;  ///< Parent entry
    size_t size;                ///< Size in bytes
    uint32_t inode;             ///< Inode index
};

/**
 * Directory entry struct
 */
struct __attribute__((__packed__)) EBFSDirectoryEntry
{
    uint32_t inode;             ///< Index of inode
    uint8_t type;               ///< Type byte
    uint8_t reserved;           ///< Reserved
    uint16_t entrySize;         ///< Size of the entry in bytes
};

/**
 * Group header
 */
struct __attribute__((__packed__)) EBFSGroupHeader
{
    uint8_t type;               ///< Type byte
    uint8_t reserved;           ///< Reserved
    uint32_t next;              ///< Next group in series
    uint32_t crc32;             ///< Group CRC32
    uint8_t reserved2[6];       ///< Reserved
};


/**
 * Superblock struct
 */
struct __attribute__((__packed__)) EBFSSuperblock
{
    uint16_t signature;         ///< Signature
    uint16_t version;           ///< Version number
    uint32_t blockSize;         ///< Size of a block in bytes
    uint32_t groupSize;         ///< Number of blocks per group
    uint32_t freeGroups;        ///< Number of free groups
    uint32_t numInodes;         ///< Total number of inodes
    uint32_t freeInodes;        ///< Number of free inodes
    uint32_t inodeSize;         ///< Size of an inode in bytes
    uint32_t lastMount;         ///< Last mount time
    uint32_t lastWrite;         ///< Last write time
    uint32_t rootDirectory;     ///< Root directory group
    uint32_t inodes;            ///< Inodes group
};

/**
 * Inode struct
 */
struct __attribute__((__packed__)) EBFSInode
{
    uint16_t type;              ///< Type and permissions
    uint16_t reserved;          ///< Reserved
    uint32_t fileSize;          ///< File size in bytes
    uint32_t lastAccess;        ///< Last access time
    uint32_t created;           ///< Creation time
    uint32_t modified;          ///< Modified time
    uint32_t group;             ///< Pointer to first group
};

/**
 * EBFS class
 */
class EBFS
{
public:
    /**
     * Constructor
     * \param root Root directory path
     * \param size Size of partition in bytes
     */
    EBFS(const std::string& root, const size_t size);

    /**
     * Destructor
     */
    ~EBFS();

    /**
     * Render partition
     * \return Partition buffer
     */
    uint8_t* render();

private:
    /**
     * Partition data
     */
    uint8_t* m_image;

    /**
     * Partition size
     */
    size_t m_size;

    /**
     * Root directory
     */
    std::string m_root;
};

/**
 * @}
 */

