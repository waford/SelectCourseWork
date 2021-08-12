#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "sched.h"

void workfunk(int count, const char *print) {
    for (int i = 0; i < count; i++) {
        for(int j = 0; j < 400000; j++) {
            if(j % 10000 == 0) {
            printf(1, print);
            }
        }
    }

}


int main(int argc, char *argv[]) {
    int rc = 0;

    
   int count = 0;
   while(count++ < 10) {
    setscheduler(getpid(), SCHED_RR, 2);
    printf(1, "\n");
    rc = fork();
    if(rc == -1) {
        printf(1, "ERRORl fork failed\n");
        workfunk(2, "Child\n");
    }

    if (rc == 0) {
        //Child
        printf(1, "2");
        workfunk(1, "b");
        printf(1, "B");
        exit();
    } else {
        //Parent
        setscheduler(rc, SCHED_RR, 1);
        setscheduler(getpid(), SCHED_RR, 0);
        printf(1, "1");
        workfunk(1, "a");
        printf(1, "A");
        wait();
    }
   }
    exit();
}