// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

char *argv[] = { "sh", 0 };
int glbl = 0;


int
main(void)
{
//  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  for(;;){
    printf(1, "init: starting sh\n");
 	
   	int rc = fork();
	if(rc == -1) {
		printf(2, "Fork Failed\n");
		while(1);
	}		
  	if(rc) {
		//Parent is runnning
		printf(1, "Parent Waits for Child\n");
		wait();
		printf(1, "Child is Done\n");
	} else {
		printf(1, "Child is Starting\n");
		glbl = 2;
		printf(1, "Global is %d\n", glbl);
		exit();
	}
	if(glbl == 2) {
		printf(1, "Parent saw child\n");
	}

	printf(1, "Init Done\n");
	while(1);

/*	pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
 */ }
}
