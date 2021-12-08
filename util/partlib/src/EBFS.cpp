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

#include "partlib/EBFS.hpp"
#include "partlib/CRC32.hpp"

#define TOTAL_INODES 256

#include <cstring>
#include <chrono>
#include <fstream>
#include <algorithm>

#include <dirent.h>
#include <sys/types.h>
#include <unistd.h>

void fetchTree(const std::string path,
        std::vector<EBFSDirectoryInfo*>& tree,
        EBFSDirectoryInfo* current = nullptr,
        const std::string name = "")
{
    if (current == nullptr)
    {
        current = new EBFSDirectoryInfo;
        current->isRoot = true;
        current->parent = nullptr;
    }

    current->isDir = true;
    current->name = name;
    current->size = sizeof(EBFSDirectoryEntry) * 2 + 3;

    DIR* dir;
    struct dirent* entry;

    if (!(dir = opendir(path.c_str())))
        return;

    while ((entry = readdir(dir)) != NULL)
    {
        if (entry->d_type == DT_DIR)
        {
            std::string newpath = entry->d_name;

            if (newpath == ".")
                continue;

            if (newpath == "..")
                continue;

            EBFSDirectoryInfo* ent = new EBFSDirectoryInfo;
            ent->name = newpath;
            ent->path = path + "/" + newpath;
            ent->isDir = true;
            ent->isRoot = false;
            ent->parent = current;

            current->children.push_back(ent);
            current->size += sizeof(EBFSDirectoryEntry) + newpath.size();

            fetchTree(path + "/" + newpath, tree, ent, newpath);
        }
        else
        {
            std::string newpath = entry->d_name;

            EBFSDirectoryInfo* ent = new EBFSDirectoryInfo;
            ent->name = newpath;
            ent->path = path + "/" + newpath;
            ent->isDir = false;
            ent->isRoot = false;
            ent->parent = current;

            auto file = std::fstream(ent->path,
                    std::ios::in | std::ios::binary | std::ios::ate);
            ent->size = file.tellg();
            file.close();

            current->children.push_back(ent);
            current->size += sizeof(EBFSDirectoryEntry) + newpath.size();

            tree.push_back(ent);
        }
    }

    closedir(dir);
    tree.push_back(current);
}

EBFS::EBFS(const std::string& root, const size_t size) :
    m_root{ root }, m_size{ size }, m_image{ nullptr }
{
    m_image = new uint8_t[size];
    memset(m_image, 0, size);
}

EBFS::~EBFS()
{
    delete m_image;
    m_image = nullptr;
}

uint8_t* EBFS::render()
{
    const auto p1 = std::chrono::system_clock::now();
    auto tm = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();

    size_t bitmapSize = (m_size / 0x200) / 8 / 8;
    size_t bitmapGroups = bitmapSize / (0x200 * 8 - 16);
    if (bitmapSize % (0x200 * 8 - 16))
        ++bitmapGroups;

    size_t inodesSize = sizeof(EBFSInode) * TOTAL_INODES;
    size_t inodesGroups = inodesSize / (0x200 * 8 - 16);
    if (inodesSize % (0x200 * 8 - 16))
        ++inodesGroups;

    std::vector<EBFSDirectoryInfo*> tree;
    fetchTree(m_root, tree);
    std::reverse(tree.begin(), tree.end());

    uint32_t nextGroup = bitmapGroups + inodesGroups;
    uint32_t rootDirectory = 0;
    uint32_t nextInode = 0;

    for (int i = 0; i < tree.size(); ++i)
    {
        if (!tree[i]->isDir)
            continue;

        tree[i]->inode = nextInode++;
    }

    for (int i = 0; i < tree.size(); ++i)
    {
        if (!tree[i]->isDir)
            continue;

        if (tree[i]->isRoot)
        {
            rootDirectory = nextGroup;
            tree[i]->inode = 0;
        }

        uint32_t dinodeGroup = bitmapGroups + (sizeof(EBFSInode) * tree[i]->inode) / (0x200 * 8 - 16);
        uint32_t dinodeOffset = (sizeof(EBFSInode) * tree[i]->inode) % (0x200 * 8 - 16) + 16;

        EBFSInode dinode;
        memset(&dinode, 0, sizeof(dinode));
        dinode.type = 0x4000 | 0x16D;
        dinode.fileSize = tree[i]->size;
        dinode.lastAccess = tm;
        dinode.created = tm;
        dinode.modified = tm;
        dinode.group = nextGroup;
        memcpy(&m_image[(dinodeGroup * 0x200 * 8) + dinodeOffset], &dinode, sizeof(dinode));

        uint8_t* dir = new uint8_t[tree[i]->size];
        uint32_t offset = 0;

        EBFSDirectoryEntry dot;
        memset(&dot, 0, sizeof(dot));
        dot.inode = tree[i]->inode;
        dot.type = 2;
        dot.entrySize = sizeof(EBFSDirectoryEntry) + 1;
        memcpy(&dir[offset], &dot, sizeof(dot));
        memcpy(&dir[offset + sizeof(EBFSDirectoryEntry)], ".", 1);
        offset += sizeof(dot) + 1;

        EBFSDirectoryEntry dotdot;
        memset(&dotdot, 0, sizeof(dotdot));
        if (tree[i]->isRoot)
            dotdot.inode = 0;
        else
            dotdot.inode = tree[i]->parent->inode;
        dotdot.type = 2;
        dotdot.entrySize = sizeof(EBFSDirectoryEntry) + 2;
        memcpy(&dir[offset], &dotdot, sizeof(dotdot));
        memcpy(&dir[offset + sizeof(dotdot)], "..", 2);
        offset += sizeof(dot) + 2;

        for (int j = 0; j < tree[i]->children.size(); ++j)
        {
            EBFSDirectoryInfo* child = tree[i]->children[j];

            if (!child->isDir)
                child->inode = nextInode++;

            EBFSDirectoryEntry dirent;
            memset(&dirent, 0, sizeof(dirent));
            dirent.inode = child->inode;
            if (child->isDir)
                dirent.type = 0x02;
            else
                dirent.type = 0x01;
            dirent.entrySize = sizeof(dirent) + child->name.size();
            memcpy(&dir[offset], &dirent, sizeof(dirent));
            memcpy(&dir[offset + sizeof(dirent)], child->name.c_str(), child->name.size());
            offset += sizeof(dirent) + child->name.size();
        }

        uint32_t numGroups = tree[i]->size / (0x200 * 8 - 16);
        if (tree[i]->size % (0x200 * 8 - 16))
            ++numGroups;

        for (int j = 0; j < numGroups; ++j, ++nextGroup)
        {
            size_t cpSize = 0x200 * 8 - 16;
            uint32_t nxtg = nextGroup + 1;

            if (j + 1 == numGroups)
            {
                cpSize = tree[i]->size % (0x200 * 8 - 16);
                nxtg = 0xFFFFFFFF;
            }

            memcpy(&m_image[nextGroup * 0x200 * 8 + 16], &dir[j * (0x200 * 8 - 16)], cpSize);

            EBFSGroupHeader ghdr;
            memset(&ghdr, 0, sizeof(ghdr));
            ghdr.type = 2;
            ghdr.next = nxtg;
            ghdr.crc32 = crc32(0, &dir[j * (0x200 * 8 - 16)], cpSize);
            memcpy(&m_image[nextGroup * 0x200 * 8], &ghdr, sizeof(ghdr));
        }

        delete dir;
        dir = nullptr;

        for (int j = 0; j < tree[i]->children.size(); ++j)
        {
            EBFSDirectoryInfo* child = tree[i]->children[j];

            if (child->isDir)
                continue;

            uint32_t inodeGroup = bitmapGroups + (sizeof(EBFSInode) * child->inode) / (0x200 * 8 - 16);
            uint32_t inodeOffset = (sizeof(EBFSInode) * child->inode) % (0x200 * 8 - 16) + 16;

            EBFSInode inode;
            memset(&inode, 0, sizeof(inode));
            inode.type = 0x816D;
            inode.fileSize = child->size;
            inode.lastAccess = tm;
            inode.created = tm;
            inode.modified = tm;
            inode.group = nextGroup;
            memcpy(&m_image[(inodeGroup * 0x200 * 8) + inodeOffset], &inode, sizeof(inode));

            numGroups = child->size / (0x200 * 8 - 16);
            if (child->size % (0x200 * 8 - 16))
                ++numGroups;

            auto file = std::fstream(child->path, std::ios::in | std::ios::binary);
            uint8_t* fbuf = new uint8_t[child->size];
            file.read((char*)fbuf, child->size);
            file.close();

            for (int k = 0; k < numGroups; ++k, ++nextGroup)
            {
                size_t cpSize = 0x200 * 8 - 16;
                uint32_t nxtg = nextGroup + 1;

                if (k + 1 == numGroups)
                {
                    cpSize = child->size % (0x200 * 8 - 16);
                    nxtg = 0xFFFFFFFF;
                }

                memcpy(&m_image[nextGroup * 0x200 * 8 + 16], &fbuf[k * (0x200 * 8 - 16)], cpSize);

                EBFSGroupHeader ghdr;
                memset(&ghdr, 0, sizeof(ghdr));
                ghdr.type = 1;
                ghdr.next = nxtg;
                ghdr.crc32 = crc32(0, &fbuf[k * (0x200 * 8 - 16)], cpSize);
                memcpy(&m_image[nextGroup * 0x200 * 8], &ghdr, sizeof(ghdr));
            }

            delete fbuf;
            fbuf = nullptr;
        }
    }

    for (int i = 0; i < inodesGroups; ++i)
    {
        uint32_t nxtg = bitmapGroups + i;

        if (i + 1 == inodesGroups)
            nxtg = 0xFFFFFFFF;

        EBFSGroupHeader ghdr;
        memset(&ghdr, 0, sizeof(ghdr));
        ghdr.type = 0x04;
        ghdr.next = nxtg;
        ghdr.crc32 = crc32(0, &m_image[(bitmapGroups + i) * 0x200 * 8 + 16], 0x200 * 8 - 16);
        memcpy(&m_image[(bitmapGroups + i) * 0x200 * 8], &ghdr, sizeof(ghdr));
    }

    for (int i = 0; i < nextGroup; ++i)
    {
        m_image[0x400 + (i / 8)] = 0x80 >> (i % 8);
    }

    for (int i = 1; i < bitmapGroups; ++i)
    {
        uint32_t nxtg = i + 1;

        if (i + 1 == bitmapGroups)
            nxtg = 0xFFFFFFFF;

        EBFSGroupHeader ghdr;
        memset(&ghdr, 0, sizeof(ghdr));
        ghdr.type = 0x03;
        ghdr.next = nxtg;
        ghdr.crc32 = crc32(0, &m_image[i * 0x200 * 8 + 16], 0x200 * 8 - 16);
        memcpy(&m_image[i * 0x200 * 8], &ghdr, sizeof(ghdr));
    }

    EBFSSuperblock super;
    memset(&super, 0, sizeof(super));
    super.signature = 0xEBF5;
    super.version = 0x0100;
    super.blockSize = 0x200;
    super.groupSize = 8;
    super.freeGroups = m_size / 0x200 / 8;
    super.numInodes = TOTAL_INODES;
    super.freeInodes = TOTAL_INODES;
    super.lastMount = tm;
    super.lastWrite = tm;
    super.rootDirectory = rootDirectory;
    super.inodes = bitmapGroups;
    memcpy(&m_image[0x200], &super, sizeof(super));
    return m_image;
}
