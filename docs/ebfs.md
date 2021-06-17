# EBFS (Ether Boot File System)

The Ether Boot File System is a simple file system designed for the Ether
boot process. It is very minimalistic for a fast and simple boot process.

## GUID

The UEFI GPT GUID for the Ether Boot File System is:

1de75ee9-a930-4d56-99a4-9a843dc9b81d

## Blocks

EBFS is divided into blocks. The size of one block is determined in the Superblock. Furthermore, blocks are divided into groups.

## Superblock

The first sector of the file system contains the superblock.
