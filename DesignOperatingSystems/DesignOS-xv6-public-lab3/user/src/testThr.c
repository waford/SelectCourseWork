#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "sched.h"

int i = 0;

void *workfunk(void *args)
{

    int count = ((int *)args)[0];
    int print = ((int *)args)[1];
    for (int i = 0; i < count; i++)
    {
        for (int j = 0; j < 400000; j++)
        {
            if (j % 100000 == 0)
            {
                printf(1, "%d", print);
            }
        }
    }
    mkdir((const char *)print);
    return 0;
}

void *testThread(void *print)
{
    int rc = fork();
    i++;
    if (rc == 0)
    {
        exit();
    }
    else
    {
        wait();
    }
    // printf(1, "\n%s\n", print);
    int tmp = thread_create(&workfunk, print);
    // printf(1, "Sarted new Thread, %d\n", tmp);
    thread_wait();
    return (void *)tmp;
}

void *threadfunc(void *fd)
{
    chdir("testdir");
    i = open("testfile2", O_CREATE | O_RDWR);
    printf((int)fd, "Thread Write \n");
    printf((int)i, "Thread Write \n");
    close((int)fd);

    return 0;
}

void * threadfunc1(void *num)
{
    int count = (int)num;
    if (num != 0)
    {
        count--;
        thread_create(&threadfunc1, (void *)count);
        printf(i, "Created thread %d\n", count);
        thread_wait();
    } else {
        printf(i, "Done!\n");
    }
    return 0;
}

int main(int argc, char *argv[])
{
    mkdir("testdir");
    int fd = open("testfile", O_CREATE | O_RDWR);
    thread_create(&threadfunc, (void *)fd);
    thread_create(&threadfunc, (void *)fd);
    thread_wait();
    thread_wait();
    int fd1 = open("testfile3", O_CREATE | O_RDWR);
    close(fd1);
    printf(fd, "Test Parent write\n");

    thread_create(&threadfunc1, (void *)10000);
    thread_wait();
    close(i);

    exit();
}