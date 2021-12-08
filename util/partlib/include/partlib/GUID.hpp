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
 * Generate random GUID
 * \param buf 16-byte buffer
 */
void generateGUID(uint8_t* buf);

/**
 * BIOS boot partition
 */
static uint8_t biosGUID[] {
    0x48, 0x61, 0x68, 0x21, 0x49, 0x64, 0x6F, 0x6E,
    0x74, 0x4E, 0x65, 0x65, 0x64, 0x45, 0x46, 0x49
};

/**
 * EBFS partition
 */
static uint8_t ebfsGUID[] {
    0x9C, 0xA8, 0x64, 0x1B, 0x29, 0x0B, 0x4A, 0xD0,
    0x95, 0x35, 0x0C, 0x53, 0x3D, 0x8A, 0x01, 0xC6
};

/**
 * @}
 */
