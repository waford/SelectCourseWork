

# Files in the "User-space library"  These are common routines (like system
#    call definitions) that user-space programs will use
set(ulib_SOURCES
  # Contains all of the system calls
  asm/usys.S

  # Common library functions
  src/ulib.c
  src/umalloc.c
  src/printf.c
  )

# User-space programs, 
set(user_SOURCES
  # Init -- the first program the kernel launchs
  src/init.c
  # The shell (launched by init)
  src/sh.c

  # Common utility programs
  src/ls.c
  )

