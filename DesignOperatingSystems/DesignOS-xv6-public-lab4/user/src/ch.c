// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"

const char *path = "testFile";
const char *path1 = "testFile1";

int main(void)
{
  printf(1, "Testing chmod & chown methods\n");
  //Just test inputs are correct
  //chmod(path, 2);
  //chown(path, 2);
  //Test invaid input
  if (chmod(path, -1) != -1 || chmod(path, 4) != -1 || chown(path, -1) != -1 || chown(path, 0xFFFF + 1) != -1)
  {
    printf(1, "Allowd invalid inupts\n");
    return -1;
  }
  //Test that stat works, and that files are initilized with correct owners
  struct stat fstat;
  if (stat(path, &fstat) == -1)
  {
    printf(1, "Creating file %s\n", path);
    int fd = open(path, O_CREATE | O_RDWR);
    stat(path, &fstat);
    close(fd);
  }
  printf(1, "Owner of %s is %d, perms %x\n", path, fstat.owner, fstat.perms);

  int rc = fork();

  if (rc == 0)
  {
    setuid(4);
    if (stat(path1, &fstat) == -1)
    {
      printf(1, "Creating file %s\n", path1);
      int fd = open(path1, O_CREATE | O_RDWR);
      chmod(path1, PROT_R);
      chown(path1, 2);
      stat(path1, &fstat);
      close(fd);
    }
    printf(1, "Owner of %s is %d, perms %x\n", path1, fstat.owner, fstat.perms);
    if(chown(path, 2) != -1 || chmod(path, PROT_R) != -1) {
      printf(1, "Failed to stop non-user from changing file metadata\n");
    }
    exit();
  }
  else
  {
    wait();
  }
  stat(path, &fstat);
  printf(1, "From root, owner of %s is %d, perms %x\n", path, fstat.owner, fstat.perms);
  printf(1, "\nchmod & chown Tests done\n");

  exit();
}
