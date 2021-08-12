#ifndef INCLUDE_STDIO_h_
#define INCLUDE_STDIO_h_

#include "stdarg.h"

#ifndef NULL
#define NULL    ((void*)0)
#endif /* !NULL */

void    cputchar(int c);
int     getchar(void);
int     iscons(int fd);

void    printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);
void vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list);
int     snprintf(char *str, int size, const char *fmt, ...);
int vsnprintf(char *str, int size, const char *fmt, va_list);

int     cprintf(const char *fmt, ...);
int vcprintf(const char *fmt, va_list);

//int     printf(const char *fmt, ...);
int     fprintf(int fd, const char *fmt, ...);
int vfprintf(int fd, const char *fmt, va_list);

char*   readline(const char *prompt);

#endif  // INCLUDE_STDIO_h_
