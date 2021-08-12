cmake_minimum_required(VERSION 3.10)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

project(xv6)

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-pic -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -Werror -fno-omit-frame-pointer -fno-stack-protector")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing -Wall -ggdb -Werror -fno-omit-frame-pointer -fno-stack-protector")

set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
set(CMAKE_C_FLAGS_DEBUG "-O0 -ggdb3")

set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}")

function(add_prefix_suffix var prefix suffix)
  set(listVar "")
  foreach(f ${ARGN})
    list(APPEND listVar "${prefix}${f}${suffix}")
  endforeach(f)
  set(${var} "${listVar}" PARENT_SCOPE)
endfunction(add_prefix_suffix)

# Build the tools!
add_subdirectory(tools)

include_directories(include)

# Kernel and bootblock
add_subdirectory(bootblock)
add_subdirectory(kernel)

# User-space applications
add_subdirectory(user)

# Whoo boy, lets build the actual boot image
add_custom_command(
  OUTPUT xv6.img
  COMMAND dd if=/dev/zero of=xv6.img count=10000
  COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/bootblock/bootblock of=xv6.img conv=notrunc
  COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel of=xv6.img seek=1 conv=notrunc
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bootblock/bootblock ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel
)

# Copy the run script
configure_file(${CMAKE_SOURCE_DIR}/scripts/xv6-qemu ${CMAKE_CURRENT_BINARY_DIR}/xv6-qemu COPYONLY)
configure_file(${CMAKE_SOURCE_DIR}/scripts/gdbinit ${CMAKE_CURRENT_BINARY_DIR}/.gdbinit COPYONLY)

# Copy the gdb script

add_custom_target(
  image ALL
  DEPENDS buildkern buildboot xv6.img makeuserfs
  #DEPENDS buildkern buildboot xv6.img
)

