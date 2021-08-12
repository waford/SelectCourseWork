project(kernel ASM)

include_directories(include)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -fno-builtin -fno-pic -m32")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m elf_i386")

include(Sources.cmake)

add_custom_command(
  OUTPUT gen/vectors.S
  COMMAND mkdir -p gen && ${CMAKE_CURRENT_SOURCE_DIR}/tools/vectors.pl > gen/vectors.S
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/vectors.pl) 

add_library(vectorobj OBJECT
  gen/vectors.S)

add_library(kernelobjs OBJECT
  ${kernel_SOURCES})

add_prefix_suffix(kernel_OBJECTS
  "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/kernelobjs.dir/"
  ".o"
  ${kernel_SOURCES})

set(entryother_SOURCES
  src/asm/entryother.S)

add_library(entryotherobjs OBJECT
  ${entryother_SOURCES})

add_prefix_suffix(entryother_OBJECTS
  "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/entryotherobjs.dir/"
  ".o"
  ${entryother_SOURCES})

set(initcode_SOURCES
  src/asm/initcode.S)

add_library(initcodeobjs OBJECT
  ${initcode_SOURCES})

add_prefix_suffix(initcode_OBJECTS
  "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/initcodeobjs.dir/"
  ".o"
  ${initcode_SOURCES})

add_custom_command(
  OUTPUT entryother.obj
  COMMAND ld -m elf_i386 -N -e start -Ttext 0x7000 -o entryother.obj ${entryother_OBJECTS}
  DEPENDS $<TARGET_OBJECTS:entryotherobjs>) 

add_custom_command(
  OUTPUT entryother
  COMMAND objcopy -S -O binary -j .text entryother.obj entryother
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/entryother.obj) 

add_custom_command(
  OUTPUT initcode.obj
  COMMAND ld -m elf_i386 -N -e start -Ttext 0 -o initcode.obj ${initcode_OBJECTS}
  DEPENDS $<TARGET_OBJECTS:initcodeobjs>) 

add_custom_command(
  OUTPUT initcode
  COMMAND objcopy -S -O binary -j .text initcode.obj initcode
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/initcode.obj) 

add_custom_command(
  OUTPUT kernel
  COMMAND ld -m elf_i386 -nostdlib -T ${CMAKE_CURRENT_SOURCE_DIR}/kernel.ld -o kernel ${kernel_OBJECTS} -b binary initcode entryother
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/kernel.ld $<TARGET_OBJECTS:kernelobjs> $<TARGET_OBJECTS:vectorobj> ${CMAKE_CURRENT_BINARY_DIR}/initcode ${CMAKE_CURRENT_BINARY_DIR}/entryother) 

add_custom_command(
  OUTPUT kernel.asm 
  COMMAND objdump -S kernel > kernel.asm
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/kernel)

add_custom_command(
  OUTPUT initcode.asm 
  COMMAND objdump -S initcode.obj > initcode.asm
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/initcode.obj)

add_custom_command(
  OUTPUT entryother.asm 
  COMMAND objdump -S entryother.obj > entryother.asm
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/entryother.obj)

add_custom_command(
  OUTPUT kernel.sym 
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/tools/mksym.sh
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/kernel)

add_custom_target(
  buildkern ALL
  # FIXME: For some reaosn I need to specify kernelobjs, entryotherobjs, and
  #   initcodeobjs, or the build system freaks out and dies (blerg)
  DEPENDS kernelobjs vectorobj entryotherobjs initcodeobjs kernel kernel.asm kernel.sym entryother.asm initcode.asm)
  #DEPENDS kernel kernel.asm kernel.sym)

set_property(TARGET kernelobjs PROPERTY C_STANDARD 11)

