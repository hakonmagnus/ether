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

using std::size_t;

/**
 * \addtogroup partlib
 * @{
 */

/**
 * Calculates the CRC32 checksum of a buffer
 * \param initial Initial CRC32 value
 * \param buf Data buffer
 * \param len Data buffer length
 * \return CRC32 value
 */
uint32_t crc32(uint32_t initial, const void* buf, size_t len);

/**
 * @}
 */

