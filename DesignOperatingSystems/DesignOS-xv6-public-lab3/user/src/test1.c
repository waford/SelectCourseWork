#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "sched.h"

int i = 0;

void workfunk(int count, const char *print)
{
    for (int i = 0; i < count; i++)
    {
        for (int j = 0; j < 400000; j++)
        {
            if (j % 100000 == 0)
            {
                printf(1, print);
            }
        }
    }
}

int main(int argc, char *argv[])
{
    int fd = open("testCloneFile", O_CREATE | O_RDWR);
    if (argc > 1)
    {
        printf(1, "Parent done\n");
        close(fd);
        printf(fd, "Parent write\n");
    }
    else
    {
        int rc = clone(malloc(4096), 4096);
        if(rc == -1) {
            printf(1, "Clone failed\n");
            exit();
        } else {
            printf(1,"RC: %d\n", rc);
        }

        if (rc == 0)
        {
            printf(fd, "Clone write 1\n");
            int rc = clone(malloc(4096), 4096);
            if(rc == 0) {
                printf(fd, "Second clone write\n");
                close(fd);
                exit();
            } else {
                //printf(fd, "Not sure if this will write or not\n");
                wait();
                printf(fd, "Test");
            }
            //close(fd);
            printf(1, "Closing proc %d\n", getpid());
            exit();
        }
        else
        {
            wait();
        }
        printf(1, "Parent done\n");
        //close(fd);
        printf(fd, "Parent write\n");
        //close(fd);
        //int size = clone((char *) 0x3000, 0x100);
        //printf(1, "Size: %d\n", size);
        // clonetest();
        //size = clone((char *) 100, 100);
        //printf(1, "%d\n", size);
    }
    exit();
}
