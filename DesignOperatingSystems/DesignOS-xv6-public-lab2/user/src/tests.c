#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"
#include "mmu.h"

char buf[8192];
char name[3];
char *echoargv[] = {"echo", "ALL", "TESTS", "PASSED", 0};
int stdout = 1;

void
assert(uint x, uint expected) {
    if (x != expected) {
        printf(1, "TEST FAILED: Expected %x, Given %x\n", expected, x);
    }
}


void
sbrkpgtest() {
    uint curr_break = (uint) sbrk(0);
    sbrk(4096);
    uint new_break = (uint) sbrk(0);

    if (new_break - curr_break != 4096) {
        printf(1, "SBRKPGTEST FAILED to grow proc by a page\n");
        exit();
    }
    sbrk(10 * 4096);
    uint new_new_break = (uint) sbrk(0);
    if (new_new_break - new_break != 10 * 4096) {
        printf(1, "SBRKPGTEST FAILED to grow proc by 10 page\n");
        exit();
    }

    printf(1, " PASSED sbrkpgtest\n");
}

void simple_fork_test() {
    printf(1, "Starting Simple Fork Test\n");
    int val = 0;
    int rc = fork();
    if (rc < 0) {
        printf(1, "SIMPLE_FORK_TEST FAILED\n");
        exit();
    }
    uint par_break = (uint) sbrk(0);
    uint child_break = (uint) sbrk(0);
    if (par_break != child_break) {
        printf(1, "SIMPLE_FORK_TEST FAILED: Parent break not the same as child\n");
        exit();
    }
    if (rc != 0) {
        val = 1;
        wait();
    } else {
        val = 2;
        exit();
    }

    if (val != 1) {
        printf(1, "SIMPLE_FORK_TEST FAILED: Parent Saw Child\n");
        exit();
    }
    printf(1, "	PASSED SIMPLE_FORK_TEST\n");
}

void zero_page_test() {
    printf(1, "STARTING ZERO_PAGE_TEST\n");
    char *start = sbrk(0);
    sbrk(4096);
    char *end = sbrk(0);
    if (start > end) { printf(1, " FAILED zero_page_test\n"); }
    for (char *i = start; i < end; i++) {
        if (*i) {
            printf(1, "  FAILED zero_page_Test\n");
            return;
        }
    }
    printf(1, "Start %x:, Start + 4096: %x, End: %x\n", start, (uint) start + 4096, end);
    memset(start, 1, 4096);

    for (char *i = end - 1; i > start; i--) {
        if (*i != 1) {
            printf(1, "FAILED zero_page_test\n");
        }
    }
    printf(1, "  PASSED zero_page_test\n");
}

void free_page_test() {
    printf(1, "\nStarting free page test \n\n");

    //Grow mem
    char *val = sbrk(4096);
    val++; //make sure its in the memory we just allocated
    int rc = fork();
    if (rc < 0) { printf(1, "Fork Failed\n"); }
    if (rc != 0) {
        //Parent Frees the memory
        sbrk(-4096);
        printf(1, "SBRK(0) %x\n", sbrk(0));
        wait();
    } else {
        //Child writes to memory
        printf(1, "Child starting\n");
        *val = 2;
        printf(1, "Val: %d\n", *val);
        exit();
    }

    printf(1, "PASSED free_page_test\n\n");
}

void grow_shrink_test() {
    printf(1, "\nSTARTING grow_shrink test\n");
    uint start = (uint) sbrk(0);
    //Grow by 100 pages
    sbrk(100 * 4096);
    assert((uint) sbrk(0), start + 100 * 4096);
    //Shrink by 50 pages
    sbrk(-50 * 4096);
    assert((uint) sbrk(0), start + 50 * 4096);
    //Grow by 25 pages
    sbrk(25 * 4096);
    assert((uint) sbrk(0), start + 75 * 4096);
    //Shrink by 75 pages
    sbrk(-75 * 4096);
    assert((uint) sbrk(0), start);

    printf(1, "PASSED grow_shrink test\n");
}

void invalid_write_test() {
    printf(1, "STARTING Invalid Write Test\n");
    //Fork proc to see if child dies when writing above sbrk
    //uint start = (uint) sbrk(0);
    printf(1, "Parent sbrk: %x\n", sbrk(0));
    int rc = fork();


    if(rc != 0 ) {
        printf(1, "Parent sbrk: %x\n", sbrk(0));
        wait();
    } else {
        printf(1, "Child sbrk: %x\n", sbrk(0));
        char* break_pnt = sbrk(0);
        break_pnt++;
        *break_pnt = 2; //<- Should be killed here
        printf(1, "FAILED: Process did not get killed\n");
        exit();
    }

    printf(1, "PASSED INVALID WRITE TEST\n");
}

void kernbase_test() {
    printf(1, "STRATING KERNBASE TEST\n");
    printf(1, "Start Page %x\n", sbrk(0));
    sbrk(KERNBASE -(uint) sbrk(0)-4096);
    printf(1, "KERNBASE: %x, SBRK %x\n", KERNBASE, sbrk(4096-1));
    printf(1, "KERNBASE: %x, SBRK %x\n", KERNBASE, sbrk(1));
    printf(1, "KERNBASE: %x, SBRK %x\n", KERNBASE, sbrk(0));
    sbrk(-KERNBASE);
    printf(1, "SBRK%x\n", sbrk(0));
}

void orphan_test(){
    printf(1, "STARTING orphan test\n");

    int rc = fork();

    if(rc != 0) {
        exit();
    } else {
        printf(1, "Child is still alive\n");
        exit();
    }
}

void invalid_write_2() {
    printf(1, "STARTING invalid write 2\n");
    int rc = fork();

    if(rc != 0) {
        int rc1 = fork(); //Second child
        if(rc1 != 0) {
            wait();
        } else {
            //Second child running
            printf(1, "Second Child running\n");
            char* write = sbrk(4096);
            *write=1;
            printf(1,"Wrote First time \n");
            while((write = sbrk(4096)) > 0){
                *write = 1;
            }
            printf(1, "Second Child: SBRK:%x\n", sbrk(0));
            printf(1, "Second was not killed\n");
            exit();
        }
        wait();
    } else {
        //First Child Running
        printf(1, "First Child running\n");
        printf(1, "First Child done\n");
        exit();
    }

}

//void large_sbrk_test() {
//    printf(1, "\nSTARTING LARGE_SBRK_TEST\n");
//    //Should be allowed to "allocate" as many zero pages as we want below KERNBASE
//    int newsz = 1 << 30;
//
//    uint start = (uint) sbrk(0);
//    uint rc = (uint) sbrk(newsz);
//    printf(1, "NEWSZ: %x, Start: %x, RC %x\n", newsz, start, rc);
//}

int
main(int argc, char *argv[]) {
    printf(1, "tests starting\n");

    if (open("tests.ran", 0) >= 0) {
        printf(1, "already ran  tests -- rebuild fs.img\n");
        exit();
    }
    close(open("usertests.ran", O_CREATE));
    sbrkpgtest();
    simple_fork_test();
    zero_page_test();
    free_page_test();
    grow_shrink_test();
    invalid_write_test();
//    orphan_test();
    invalid_write_2();
    exit();
}
