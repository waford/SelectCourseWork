// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"
#include "stat.h"

const char *path = "testPermFile";
const char *path1 = "testPermFile1";
const char *path2 = "testPermFile2";
const char *path3 = "testPermFile3";
const char *dir1 = "testdir1";
const char *dir2 = "testdir2";


int main(void)
{
  printf(1, "Testing Perms1 methods\n");
  setuid(1);
  int fd, fd1, fd2,fd3;
  //Test Opening each file as RDWR
  fd = open(path, O_RDWR);
  fd1 = open(path1, O_RDWR);
  fd2 = open(path2, O_RDWR);
  fd3 = open(path3, O_RDWR);

  //only fd2 should be positive
  if(fd != -1 || fd1 != -1 || fd2 <0 || fd3 != -1) {
    printf(1, "Failed to properly open files\n");
  }
  printf(1,"fd %d, fd1 %d, fd2 %d, fd3 %d\n", fd,fd1,fd2,fd3);


  //Open with proper permissions
  if((fd = open(path, O_RDONLY)) == -1 || (fd1 = open(path1, O_WRONLY)) == -1)
    printf(1, "Failed to properly open files\n");

  
  printf(1,"fd %d, fd1 %d, fd2 %d, fd3 %d\n", fd,fd1,fd2,fd3);
  //Try to read fd
  printf(1, "Reading from file %d\n", fd);
  char buf[512];
  int n = read(fd, buf, sizeof(buf));
  write(1, buf, n);
  printf(fd2, "User 1 write\n");

  //Check fstat
  struct stat fstat;
  stat(path, &fstat);
  if(fstat.ino == 0) {
    printf(1, "Failed to read file\n");
  }
  printf(1, "%s ino %d\n", path, fstat.ino);
  int test = stat(path1, &fstat);
  if(test != -1) {
    printf(1, "Failed to prevent read file\n");
    printf(1, "Test: %d\n", test);
  }
  printf(1, "%s ino %d\n", path1, fstat.ino);

  if(chdir(dir1) != -1) {
    printf(1, "Failed to stop changing dirs(1)\n");
    mknod("lol", 0,0);
  } 
  // if(stat(dir2, &fstat) != -1) {
  //   printf(1, "Perms: %x\n", fstat.perms);
  // }

  if(chdir(dir2) == -1) {
    printf(1, "Failed to allow changing dirs(2)");
  }
  mknod("test",0,0);
  chdir("/");


  close(fd);
  close(fd1);
  close(fd2);
  close(fd3);

  int one = mknod("a/b/test",0,0);
  int two = mknod("a/b/c/test",0,0);
  printf(1,"First write %d, Second write %d\n", one, two);

  printf(1, "Result of unlink %d\n",unlink("a/b/remove"));
  printf(1, "Result of unlink %d\n",unlink("a/b/c/remove"));
  printf(1, "\nPerms1 Test done\n");

  exit();
}
