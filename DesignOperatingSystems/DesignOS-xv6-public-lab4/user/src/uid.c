// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"


int
main(void)
{
 printf(1, "Testing User ID methods\n");
 //Check that uid starts at 0
 printf(1, "Starting uid %d\n", getuid());

 //Test invalid users ids 
 if(setuid(-1) != -1 || setuid(0xFFFF+1) != -1) {
   printf(1, "Allowed userid to take invalid inputs\n");
   return 0;
 }

 int rc = fork();

 if (rc == 0) {
   //Verify uid is 0 (i.e. inherited)
   if(getuid() != 0) {
     printf(1, "Failed to inherit uid\n");
   }
   setuid(1);
   if(getuid() != 1) {
     printf(1, "Failed to set uid to 1\n");
   }
   //Veriy non-root can not change uid
   if(setuid(2) != -1) {
     printf(1, "Failed to prevent non-root from changing their uid\n");
   }
   exit();
 } else {
   wait();
 }
  printf(1,"USER ID Tests done\n");
  exit();
}
