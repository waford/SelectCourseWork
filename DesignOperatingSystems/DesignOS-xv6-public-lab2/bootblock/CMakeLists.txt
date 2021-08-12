project(bootblock ASM)

include_directories(include)

set(bootblock_SOURCES
  # NOTE: bootasm.S must go first in this list, to ensure its placed at 0x7c00
  #   in the bootloader dump
  bootasm.S
  bootmain.c)

add_library(bootblockobjs OBJECT
  ${bootblock_SOURCES})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -fno-builtin -fno-pic -nostdinc -m32")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m elf_i386")

# Always force -Os for bootblock
set(CMAKE_C_FLAGS_RELEASE "-Os")
set(CMAKE_C_FLAGS_DEBUG "-Os -ggdb3")

add_prefix_suffix(bootblock_OBJECTS
  "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/bootblockobjs.dir/"
  ".o"
  ${bootblock_SOURCES})

add_custom_command(
  OUTPUT bootblock.obj
  COMMAND ${CMAKE_LINKER} -m elf_i386 -N -e start -Ttext 0x7C00 -o ${CMAKE_CURRENT_BINARY_DIR}/bootblock.obj ${bootblock_OBJECTS}
  DEPENDS $<TARGET_OBJECTS:bootblockobjs>)

add_custom_command(
  OUTPUT bootblock
  COMMAND objcopy -S -O binary -j .text bootblock.obj bootblock
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/tools/sign.pl bootblock
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bootblock.obj)

add_custom_command(
  OUTPUT bootblock.asm 
  COMMAND objdump -S bootblock.obj > bootblock.asm
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bootblock.obj)

add_custom_target(
  buildboot ALL
  DEPENDS bootblockobjs bootblock.asm bootblock)

set_property(TARGET bootblockobjs PROPERTY C_STANDARD 11)


