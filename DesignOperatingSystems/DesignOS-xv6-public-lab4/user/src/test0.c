// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"


int
main(void)
{
  printf(1, "TEST 0 Starting!\n");
  //Check that userid is 0
  if (getuid() != 0) {
    printf(1, "TEST 0: User ID did not start at 0\n");
    return 0;
  }
  //Change userid to 1
  if(setuid(1) != 0) {
    printf(1, "TEST 0: UserID failed\n");
    return 0;
  }
  //Checkt that tht change is reflected
  if(getuid() != 1) {
    printf(1, "TEST 0: Failed to set userid to 1\n");
    return 0;
  }
  //Test that we can not set the user id anymore
  if(setuid(2) != -1) {
    printf(1, "TEST 0: Was allowed to change userid when uid != 0\n");
    return 0;
  }
  //Fork and check 
  int rc = fork();
  if(rc == 0) {
    if(getuid() != 1) {
      printf(1, "TEST 0: Failed to set uid properly in fork\n");
    }
    exit();
  } else {
    wait();
  }
  printf(1,"TEST 0: All tests passed!\n");
  exit();
}
