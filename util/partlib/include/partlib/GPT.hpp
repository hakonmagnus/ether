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

#include <cstdint>

/**
 * \addtogroup partlib
 * @{
 */

/**
 * GPT header structure
 */
struct __attribute__((__packed__)) GPTHeader
{
    char signature[8];          ///< EFI PART
    uint32_t revision;          ///< Revision 1.0 or 0x00010000
    uint32_t headerSize;        ///< 0x5C
    uint32_t headerCRC32;       ///< CRC32 checksum of header
    uint32_t reserved;          ///< Zero
    uint64_t currentLBA;        ///< LBA of this header copy
    uint64_t backupLBA;         ///< LBA of other header copy
    uint64_t firstUsableLBA;    ///< First usable LBA for partitions
    uint64_t lastUsableLBA;     ///< Last usable LBA for partitions
    uint8_t diskGUID[16];       ///< Unique disk GUID
    uint64_t entriesLBA;        ///< LBA of partition entries
    uint32_t numEntries;        ///< Number of partition entries
    uint32_t entrySize;         ///< 0x80
    uint32_t entriesCRC32;      ///< CRC32 checksum of entries
};

/**
 * GPT entry structure
 */
struct __attribute__((__packed__)) GPTEntry
{
    uint8_t typeGUID[16];       ///< Type GUID
    uint8_t uniqueGUID[16];     ///< Unique GUID
    uint64_t firstLBA;          ///< Start of partition
    uint64_t lastLBA;           ///< End of partition
    uint64_t flags;             ///< Attribute flags
    char16_t partitionName[36]; ///< Partition name in UTF-16
};

/**
 * @}
 */
