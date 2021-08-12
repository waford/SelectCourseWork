
_init1:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { xstr(TESTPROG), 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  11:	83 ec 08             	sub    $0x8,%esp
  14:	6a 02                	push   $0x2
  16:	68 c0 08 00 00       	push   $0x8c0
  1b:	e8 62 01 00 00       	call   182 <open>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	79 26                	jns    4d <main+0x4d>
    mknod("console", 1, 1);
  27:	83 ec 04             	sub    $0x4,%esp
  2a:	6a 01                	push   $0x1
  2c:	6a 01                	push   $0x1
  2e:	68 c0 08 00 00       	push   $0x8c0
  33:	e8 52 01 00 00       	call   18a <mknod>
  38:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	6a 02                	push   $0x2
  40:	68 c0 08 00 00       	push   $0x8c0
  45:	e8 38 01 00 00       	call   182 <open>
  4a:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  4d:	83 ec 0c             	sub    $0xc,%esp
  50:	6a 00                	push   $0x0
  52:	e8 63 01 00 00       	call   1ba <dup>
  57:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 56 01 00 00       	call   1ba <dup>
  64:	83 c4 10             	add    $0x10,%esp

  for(;;) {
    printf(1, "init: starting " xstr(TESTPROG) "\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 c8 08 00 00       	push   $0x8c8
  6f:	6a 01                	push   $0x1
  71:	e8 b3 06 00 00       	call   729 <printf>
  76:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  79:	e8 bc 00 00 00       	call   13a <fork>
  7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  85:	79 17                	jns    9e <main+0x9e>
      printf(1, "init: fork failed\n");
  87:	83 ec 08             	sub    $0x8,%esp
  8a:	68 de 08 00 00       	push   $0x8de
  8f:	6a 01                	push   $0x1
  91:	e8 93 06 00 00       	call   729 <printf>
  96:	83 c4 10             	add    $0x10,%esp
      exit();
  99:	e8 a4 00 00 00       	call   142 <exit>
    }
    if(pid == 0) {
  9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a2:	75 77                	jne    11b <main+0x11b>
      int pid;

      printf(1, "!TESTSTART!\n");
  a4:	83 ec 08             	sub    $0x8,%esp
  a7:	68 f1 08 00 00       	push   $0x8f1
  ac:	6a 01                	push   $0x1
  ae:	e8 76 06 00 00       	call   729 <printf>
  b3:	83 c4 10             	add    $0x10,%esp
      pid = fork();
  b6:	e8 7f 00 00 00       	call   13a <fork>
  bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (pid == 0) {
  be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  c2:	75 2c                	jne    f0 <main+0xf0>
        exec(xstr(TESTPROG), argv);
  c4:	83 ec 08             	sub    $0x8,%esp
  c7:	68 78 0b 00 00       	push   $0xb78
  cc:	68 ba 08 00 00       	push   $0x8ba
  d1:	e8 a4 00 00 00       	call   17a <exec>
  d6:	83 c4 10             	add    $0x10,%esp
        printf(1, "init: exec " xstr(TESTPROG) " failed\n");
  d9:	83 ec 08             	sub    $0x8,%esp
  dc:	68 fe 08 00 00       	push   $0x8fe
  e1:	6a 01                	push   $0x1
  e3:	e8 41 06 00 00       	call   729 <printf>
  e8:	83 c4 10             	add    $0x10,%esp
        exit();
  eb:	e8 52 00 00 00       	call   142 <exit>
      }
      wait();
  f0:	e8 55 00 00 00       	call   14a <wait>
      printf(1, "!TESTEND!\n");
  f5:	83 ec 08             	sub    $0x8,%esp
  f8:	68 17 09 00 00       	push   $0x917
  fd:	6a 01                	push   $0x1
  ff:	e8 25 06 00 00       	call   729 <printf>
 104:	83 c4 10             	add    $0x10,%esp

      // Just spin after testend
      while (1) ;
 107:	eb fe                	jmp    107 <main+0x107>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
 109:	83 ec 08             	sub    $0x8,%esp
 10c:	68 22 09 00 00       	push   $0x922
 111:	6a 01                	push   $0x1
 113:	e8 11 06 00 00       	call   729 <printf>
 118:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
 11b:	e8 2a 00 00 00       	call   14a <wait>
 120:	89 45 f0             	mov    %eax,-0x10(%ebp)
 123:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 127:	0f 88 3a ff ff ff    	js     67 <main+0x67>
 12d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 130:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 133:	75 d4                	jne    109 <main+0x109>
    printf(1, "init: starting " xstr(TESTPROG) "\n");
 135:	e9 2d ff ff ff       	jmp    67 <main+0x67>

0000013a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 13a:	b8 01 00 00 00       	mov    $0x1,%eax
 13f:	cd 40                	int    $0x40
 141:	c3                   	ret    

00000142 <exit>:
SYSCALL(exit)
 142:	b8 02 00 00 00       	mov    $0x2,%eax
 147:	cd 40                	int    $0x40
 149:	c3                   	ret    

0000014a <wait>:
SYSCALL(wait)
 14a:	b8 03 00 00 00       	mov    $0x3,%eax
 14f:	cd 40                	int    $0x40
 151:	c3                   	ret    

00000152 <pipe>:
SYSCALL(pipe)
 152:	b8 04 00 00 00       	mov    $0x4,%eax
 157:	cd 40                	int    $0x40
 159:	c3                   	ret    

0000015a <read>:
SYSCALL(read)
 15a:	b8 05 00 00 00       	mov    $0x5,%eax
 15f:	cd 40                	int    $0x40
 161:	c3                   	ret    

00000162 <write>:
SYSCALL(write)
 162:	b8 10 00 00 00       	mov    $0x10,%eax
 167:	cd 40                	int    $0x40
 169:	c3                   	ret    

0000016a <close>:
SYSCALL(close)
 16a:	b8 15 00 00 00       	mov    $0x15,%eax
 16f:	cd 40                	int    $0x40
 171:	c3                   	ret    

00000172 <kill>:
SYSCALL(kill)
 172:	b8 06 00 00 00       	mov    $0x6,%eax
 177:	cd 40                	int    $0x40
 179:	c3                   	ret    

0000017a <exec>:
SYSCALL(exec)
 17a:	b8 07 00 00 00       	mov    $0x7,%eax
 17f:	cd 40                	int    $0x40
 181:	c3                   	ret    

00000182 <open>:
SYSCALL(open)
 182:	b8 0f 00 00 00       	mov    $0xf,%eax
 187:	cd 40                	int    $0x40
 189:	c3                   	ret    

0000018a <mknod>:
SYSCALL(mknod)
 18a:	b8 11 00 00 00       	mov    $0x11,%eax
 18f:	cd 40                	int    $0x40
 191:	c3                   	ret    

00000192 <unlink>:
SYSCALL(unlink)
 192:	b8 12 00 00 00       	mov    $0x12,%eax
 197:	cd 40                	int    $0x40
 199:	c3                   	ret    

0000019a <fstat>:
SYSCALL(fstat)
 19a:	b8 08 00 00 00       	mov    $0x8,%eax
 19f:	cd 40                	int    $0x40
 1a1:	c3                   	ret    

000001a2 <link>:
SYSCALL(link)
 1a2:	b8 13 00 00 00       	mov    $0x13,%eax
 1a7:	cd 40                	int    $0x40
 1a9:	c3                   	ret    

000001aa <mkdir>:
SYSCALL(mkdir)
 1aa:	b8 14 00 00 00       	mov    $0x14,%eax
 1af:	cd 40                	int    $0x40
 1b1:	c3                   	ret    

000001b2 <chdir>:
SYSCALL(chdir)
 1b2:	b8 09 00 00 00       	mov    $0x9,%eax
 1b7:	cd 40                	int    $0x40
 1b9:	c3                   	ret    

000001ba <dup>:
SYSCALL(dup)
 1ba:	b8 0a 00 00 00       	mov    $0xa,%eax
 1bf:	cd 40                	int    $0x40
 1c1:	c3                   	ret    

000001c2 <getpid>:
SYSCALL(getpid)
 1c2:	b8 0b 00 00 00       	mov    $0xb,%eax
 1c7:	cd 40                	int    $0x40
 1c9:	c3                   	ret    

000001ca <sbrk>:
SYSCALL(sbrk)
 1ca:	b8 0c 00 00 00       	mov    $0xc,%eax
 1cf:	cd 40                	int    $0x40
 1d1:	c3                   	ret    

000001d2 <sleep>:
SYSCALL(sleep)
 1d2:	b8 0d 00 00 00       	mov    $0xd,%eax
 1d7:	cd 40                	int    $0x40
 1d9:	c3                   	ret    

000001da <uptime>:
SYSCALL(uptime)
 1da:	b8 0e 00 00 00       	mov    $0xe,%eax
 1df:	cd 40                	int    $0x40
 1e1:	c3                   	ret    

000001e2 <stosb>:
  __asm__ volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	57                   	push   %edi
 1e6:	53                   	push   %ebx
  __asm__ volatile("cld; rep stosb" :
 1e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1ea:	8b 55 10             	mov    0x10(%ebp),%edx
 1ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f0:	89 cb                	mov    %ecx,%ebx
 1f2:	89 df                	mov    %ebx,%edi
 1f4:	89 d1                	mov    %edx,%ecx
 1f6:	fc                   	cld    
 1f7:	f3 aa                	rep stos %al,%es:(%edi)
 1f9:	89 ca                	mov    %ecx,%edx
 1fb:	89 fb                	mov    %edi,%ebx
 1fd:	89 5d 08             	mov    %ebx,0x8(%ebp)
 200:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 203:	90                   	nop
 204:	5b                   	pop    %ebx
 205:	5f                   	pop    %edi
 206:	5d                   	pop    %ebp
 207:	c3                   	ret    

00000208 <strcpy>:
#include "user.h"
#include "asm/x86.h"

char*
strcpy(char *s, const char *t)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 214:	90                   	nop
 215:	8b 55 0c             	mov    0xc(%ebp),%edx
 218:	8d 42 01             	lea    0x1(%edx),%eax
 21b:	89 45 0c             	mov    %eax,0xc(%ebp)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	8d 48 01             	lea    0x1(%eax),%ecx
 224:	89 4d 08             	mov    %ecx,0x8(%ebp)
 227:	0f b6 12             	movzbl (%edx),%edx
 22a:	88 10                	mov    %dl,(%eax)
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	84 c0                	test   %al,%al
 231:	75 e2                	jne    215 <strcpy+0xd>
    ;
  return os;
 233:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 236:	c9                   	leave  
 237:	c3                   	ret    

00000238 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 23b:	eb 08                	jmp    245 <strcmp+0xd>
    p++, q++;
 23d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 241:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	0f b6 00             	movzbl (%eax),%eax
 24b:	84 c0                	test   %al,%al
 24d:	74 10                	je     25f <strcmp+0x27>
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 10             	movzbl (%eax),%edx
 255:	8b 45 0c             	mov    0xc(%ebp),%eax
 258:	0f b6 00             	movzbl (%eax),%eax
 25b:	38 c2                	cmp    %al,%dl
 25d:	74 de                	je     23d <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	0f b6 00             	movzbl (%eax),%eax
 265:	0f b6 d0             	movzbl %al,%edx
 268:	8b 45 0c             	mov    0xc(%ebp),%eax
 26b:	0f b6 00             	movzbl (%eax),%eax
 26e:	0f b6 c0             	movzbl %al,%eax
 271:	29 c2                	sub    %eax,%edx
 273:	89 d0                	mov    %edx,%eax
}
 275:	5d                   	pop    %ebp
 276:	c3                   	ret    

00000277 <strlen>:

uint
strlen(const char *s)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 27d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 284:	eb 04                	jmp    28a <strlen+0x13>
 286:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 28a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	01 d0                	add    %edx,%eax
 292:	0f b6 00             	movzbl (%eax),%eax
 295:	84 c0                	test   %al,%al
 297:	75 ed                	jne    286 <strlen+0xf>
    ;
  return n;
 299:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29c:	c9                   	leave  
 29d:	c3                   	ret    

0000029e <memset>:

void*
memset(void *dst, int c, uint n)
{
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2a1:	8b 45 10             	mov    0x10(%ebp),%eax
 2a4:	50                   	push   %eax
 2a5:	ff 75 0c             	pushl  0xc(%ebp)
 2a8:	ff 75 08             	pushl  0x8(%ebp)
 2ab:	e8 32 ff ff ff       	call   1e2 <stosb>
 2b0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b6:	c9                   	leave  
 2b7:	c3                   	ret    

000002b8 <strchr>:

char*
strchr(const char *s, char c)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	83 ec 04             	sub    $0x4,%esp
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2c4:	eb 14                	jmp    2da <strchr+0x22>
    if(*s == c)
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	0f b6 00             	movzbl (%eax),%eax
 2cc:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2cf:	75 05                	jne    2d6 <strchr+0x1e>
      return (char*)s;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	eb 13                	jmp    2e9 <strchr+0x31>
  for(; *s; s++)
 2d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	0f b6 00             	movzbl (%eax),%eax
 2e0:	84 c0                	test   %al,%al
 2e2:	75 e2                	jne    2c6 <strchr+0xe>
  return 0;
 2e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2e9:	c9                   	leave  
 2ea:	c3                   	ret    

000002eb <gets>:

char*
gets(char *buf, int max)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f8:	eb 42                	jmp    33c <gets+0x51>
    cc = read(0, &c, 1);
 2fa:	83 ec 04             	sub    $0x4,%esp
 2fd:	6a 01                	push   $0x1
 2ff:	8d 45 ef             	lea    -0x11(%ebp),%eax
 302:	50                   	push   %eax
 303:	6a 00                	push   $0x0
 305:	e8 50 fe ff ff       	call   15a <read>
 30a:	83 c4 10             	add    $0x10,%esp
 30d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 310:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 314:	7e 33                	jle    349 <gets+0x5e>
      break;
    buf[i++] = c;
 316:	8b 45 f4             	mov    -0xc(%ebp),%eax
 319:	8d 50 01             	lea    0x1(%eax),%edx
 31c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 31f:	89 c2                	mov    %eax,%edx
 321:	8b 45 08             	mov    0x8(%ebp),%eax
 324:	01 c2                	add    %eax,%edx
 326:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 32c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 330:	3c 0a                	cmp    $0xa,%al
 332:	74 16                	je     34a <gets+0x5f>
 334:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 338:	3c 0d                	cmp    $0xd,%al
 33a:	74 0e                	je     34a <gets+0x5f>
  for(i=0; i+1 < max; ){
 33c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33f:	83 c0 01             	add    $0x1,%eax
 342:	39 45 0c             	cmp    %eax,0xc(%ebp)
 345:	7f b3                	jg     2fa <gets+0xf>
 347:	eb 01                	jmp    34a <gets+0x5f>
      break;
 349:	90                   	nop
      break;
  }
  buf[i] = '\0';
 34a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	01 d0                	add    %edx,%eax
 352:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 355:	8b 45 08             	mov    0x8(%ebp),%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <stat>:

int
stat(const char *n, struct stat *st)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 360:	83 ec 08             	sub    $0x8,%esp
 363:	6a 00                	push   $0x0
 365:	ff 75 08             	pushl  0x8(%ebp)
 368:	e8 15 fe ff ff       	call   182 <open>
 36d:	83 c4 10             	add    $0x10,%esp
 370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 377:	79 07                	jns    380 <stat+0x26>
    return -1;
 379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 37e:	eb 25                	jmp    3a5 <stat+0x4b>
  r = fstat(fd, st);
 380:	83 ec 08             	sub    $0x8,%esp
 383:	ff 75 0c             	pushl  0xc(%ebp)
 386:	ff 75 f4             	pushl  -0xc(%ebp)
 389:	e8 0c fe ff ff       	call   19a <fstat>
 38e:	83 c4 10             	add    $0x10,%esp
 391:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 394:	83 ec 0c             	sub    $0xc,%esp
 397:	ff 75 f4             	pushl  -0xc(%ebp)
 39a:	e8 cb fd ff ff       	call   16a <close>
 39f:	83 c4 10             	add    $0x10,%esp
  return r;
 3a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <atoi>:

int
atoi(const char *s)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b4:	eb 25                	jmp    3db <atoi+0x34>
    n = n*10 + *s++ - '0';
 3b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b9:	89 d0                	mov    %edx,%eax
 3bb:	c1 e0 02             	shl    $0x2,%eax
 3be:	01 d0                	add    %edx,%eax
 3c0:	01 c0                	add    %eax,%eax
 3c2:	89 c1                	mov    %eax,%ecx
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	8d 50 01             	lea    0x1(%eax),%edx
 3ca:	89 55 08             	mov    %edx,0x8(%ebp)
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	0f be c0             	movsbl %al,%eax
 3d3:	01 c8                	add    %ecx,%eax
 3d5:	83 e8 30             	sub    $0x30,%eax
 3d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	0f b6 00             	movzbl (%eax),%eax
 3e1:	3c 2f                	cmp    $0x2f,%al
 3e3:	7e 0a                	jle    3ef <atoi+0x48>
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	3c 39                	cmp    $0x39,%al
 3ed:	7e c7                	jle    3b6 <atoi+0xf>
  return n;
 3ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 406:	eb 17                	jmp    41f <memmove+0x2b>
    *dst++ = *src++;
 408:	8b 55 f8             	mov    -0x8(%ebp),%edx
 40b:	8d 42 01             	lea    0x1(%edx),%eax
 40e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 411:	8b 45 fc             	mov    -0x4(%ebp),%eax
 414:	8d 48 01             	lea    0x1(%eax),%ecx
 417:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 41a:	0f b6 12             	movzbl (%edx),%edx
 41d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 41f:	8b 45 10             	mov    0x10(%ebp),%eax
 422:	8d 50 ff             	lea    -0x1(%eax),%edx
 425:	89 55 10             	mov    %edx,0x10(%ebp)
 428:	85 c0                	test   %eax,%eax
 42a:	7f dc                	jg     408 <memmove+0x14>
  return vdst;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	83 e8 08             	sub    $0x8,%eax
 43d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 440:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 445:	89 45 fc             	mov    %eax,-0x4(%ebp)
 448:	eb 24                	jmp    46e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 44a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 44d:	8b 00                	mov    (%eax),%eax
 44f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 452:	72 12                	jb     466 <free+0x35>
 454:	8b 45 f8             	mov    -0x8(%ebp),%eax
 457:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 45a:	77 24                	ja     480 <free+0x4f>
 45c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 45f:	8b 00                	mov    (%eax),%eax
 461:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 464:	72 1a                	jb     480 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 466:	8b 45 fc             	mov    -0x4(%ebp),%eax
 469:	8b 00                	mov    (%eax),%eax
 46b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 46e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 471:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 474:	76 d4                	jbe    44a <free+0x19>
 476:	8b 45 fc             	mov    -0x4(%ebp),%eax
 479:	8b 00                	mov    (%eax),%eax
 47b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 47e:	73 ca                	jae    44a <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 480:	8b 45 f8             	mov    -0x8(%ebp),%eax
 483:	8b 40 04             	mov    0x4(%eax),%eax
 486:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 48d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 490:	01 c2                	add    %eax,%edx
 492:	8b 45 fc             	mov    -0x4(%ebp),%eax
 495:	8b 00                	mov    (%eax),%eax
 497:	39 c2                	cmp    %eax,%edx
 499:	75 24                	jne    4bf <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 49b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 49e:	8b 50 04             	mov    0x4(%eax),%edx
 4a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4a4:	8b 00                	mov    (%eax),%eax
 4a6:	8b 40 04             	mov    0x4(%eax),%eax
 4a9:	01 c2                	add    %eax,%edx
 4ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4ae:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 4b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b4:	8b 00                	mov    (%eax),%eax
 4b6:	8b 10                	mov    (%eax),%edx
 4b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4bb:	89 10                	mov    %edx,(%eax)
 4bd:	eb 0a                	jmp    4c9 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 4bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4c2:	8b 10                	mov    (%eax),%edx
 4c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4c7:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 4c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4cc:	8b 40 04             	mov    0x4(%eax),%eax
 4cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 4d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d9:	01 d0                	add    %edx,%eax
 4db:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 4de:	75 20                	jne    500 <free+0xcf>
    p->s.size += bp->s.size;
 4e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4e3:	8b 50 04             	mov    0x4(%eax),%edx
 4e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4e9:	8b 40 04             	mov    0x4(%eax),%eax
 4ec:	01 c2                	add    %eax,%edx
 4ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4f1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4f7:	8b 10                	mov    (%eax),%edx
 4f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4fc:	89 10                	mov    %edx,(%eax)
 4fe:	eb 08                	jmp    508 <free+0xd7>
  } else
    p->s.ptr = bp;
 500:	8b 45 fc             	mov    -0x4(%ebp),%eax
 503:	8b 55 f8             	mov    -0x8(%ebp),%edx
 506:	89 10                	mov    %edx,(%eax)
  freep = p;
 508:	8b 45 fc             	mov    -0x4(%ebp),%eax
 50b:	a3 9c 0b 00 00       	mov    %eax,0xb9c
}
 510:	90                   	nop
 511:	c9                   	leave  
 512:	c3                   	ret    

00000513 <morecore>:

static Header*
morecore(uint nu)
{
 513:	55                   	push   %ebp
 514:	89 e5                	mov    %esp,%ebp
 516:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 519:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 520:	77 07                	ja     529 <morecore+0x16>
    nu = 4096;
 522:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	c1 e0 03             	shl    $0x3,%eax
 52f:	83 ec 0c             	sub    $0xc,%esp
 532:	50                   	push   %eax
 533:	e8 92 fc ff ff       	call   1ca <sbrk>
 538:	83 c4 10             	add    $0x10,%esp
 53b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 53e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 542:	75 07                	jne    54b <morecore+0x38>
    return 0;
 544:	b8 00 00 00 00       	mov    $0x0,%eax
 549:	eb 26                	jmp    571 <morecore+0x5e>
  hp = (Header*)p;
 54b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 551:	8b 45 f0             	mov    -0x10(%ebp),%eax
 554:	8b 55 08             	mov    0x8(%ebp),%edx
 557:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 55a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55d:	83 c0 08             	add    $0x8,%eax
 560:	83 ec 0c             	sub    $0xc,%esp
 563:	50                   	push   %eax
 564:	e8 c8 fe ff ff       	call   431 <free>
 569:	83 c4 10             	add    $0x10,%esp
  return freep;
 56c:	a1 9c 0b 00 00       	mov    0xb9c,%eax
}
 571:	c9                   	leave  
 572:	c3                   	ret    

00000573 <malloc>:

void*
malloc(uint nbytes)
{
 573:	55                   	push   %ebp
 574:	89 e5                	mov    %esp,%ebp
 576:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	83 c0 07             	add    $0x7,%eax
 57f:	c1 e8 03             	shr    $0x3,%eax
 582:	83 c0 01             	add    $0x1,%eax
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 588:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 58d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 590:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 594:	75 23                	jne    5b9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 596:	c7 45 f0 94 0b 00 00 	movl   $0xb94,-0x10(%ebp)
 59d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a0:	a3 9c 0b 00 00       	mov    %eax,0xb9c
 5a5:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 5aa:	a3 94 0b 00 00       	mov    %eax,0xb94
    base.s.size = 0;
 5af:	c7 05 98 0b 00 00 00 	movl   $0x0,0xb98
 5b6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5bc:	8b 00                	mov    (%eax),%eax
 5be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 5c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c4:	8b 40 04             	mov    0x4(%eax),%eax
 5c7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 5ca:	77 4d                	ja     619 <malloc+0xa6>
      if(p->s.size == nunits)
 5cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cf:	8b 40 04             	mov    0x4(%eax),%eax
 5d2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 5d5:	75 0c                	jne    5e3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 5d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5da:	8b 10                	mov    (%eax),%edx
 5dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5df:	89 10                	mov    %edx,(%eax)
 5e1:	eb 26                	jmp    609 <malloc+0x96>
      else {
        p->s.size -= nunits;
 5e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e6:	8b 40 04             	mov    0x4(%eax),%eax
 5e9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 5ec:	89 c2                	mov    %eax,%edx
 5ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f7:	8b 40 04             	mov    0x4(%eax),%eax
 5fa:	c1 e0 03             	shl    $0x3,%eax
 5fd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 600:	8b 45 f4             	mov    -0xc(%ebp),%eax
 603:	8b 55 ec             	mov    -0x14(%ebp),%edx
 606:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 609:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60c:	a3 9c 0b 00 00       	mov    %eax,0xb9c
      return (void*)(p + 1);
 611:	8b 45 f4             	mov    -0xc(%ebp),%eax
 614:	83 c0 08             	add    $0x8,%eax
 617:	eb 3b                	jmp    654 <malloc+0xe1>
    }
    if(p == freep)
 619:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 61e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 621:	75 1e                	jne    641 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 623:	83 ec 0c             	sub    $0xc,%esp
 626:	ff 75 ec             	pushl  -0x14(%ebp)
 629:	e8 e5 fe ff ff       	call   513 <morecore>
 62e:	83 c4 10             	add    $0x10,%esp
 631:	89 45 f4             	mov    %eax,-0xc(%ebp)
 634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 638:	75 07                	jne    641 <malloc+0xce>
        return 0;
 63a:	b8 00 00 00 00       	mov    $0x0,%eax
 63f:	eb 13                	jmp    654 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 641:	8b 45 f4             	mov    -0xc(%ebp),%eax
 644:	89 45 f0             	mov    %eax,-0x10(%ebp)
 647:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64a:	8b 00                	mov    (%eax),%eax
 64c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 64f:	e9 6d ff ff ff       	jmp    5c1 <malloc+0x4e>
  }
}
 654:	c9                   	leave  
 655:	c3                   	ret    

00000656 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 656:	55                   	push   %ebp
 657:	89 e5                	mov    %esp,%ebp
 659:	83 ec 18             	sub    $0x18,%esp
 65c:	8b 45 0c             	mov    0xc(%ebp),%eax
 65f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 662:	83 ec 04             	sub    $0x4,%esp
 665:	6a 01                	push   $0x1
 667:	8d 45 f4             	lea    -0xc(%ebp),%eax
 66a:	50                   	push   %eax
 66b:	ff 75 08             	pushl  0x8(%ebp)
 66e:	e8 ef fa ff ff       	call   162 <write>
 673:	83 c4 10             	add    $0x10,%esp
}
 676:	90                   	nop
 677:	c9                   	leave  
 678:	c3                   	ret    

00000679 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 679:	55                   	push   %ebp
 67a:	89 e5                	mov    %esp,%ebp
 67c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 67f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 686:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 68a:	74 17                	je     6a3 <printint+0x2a>
 68c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 690:	79 11                	jns    6a3 <printint+0x2a>
    neg = 1;
 692:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 699:	8b 45 0c             	mov    0xc(%ebp),%eax
 69c:	f7 d8                	neg    %eax
 69e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a1:	eb 06                	jmp    6a9 <printint+0x30>
  } else {
    x = xx;
 6a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b6:	ba 00 00 00 00       	mov    $0x0,%edx
 6bb:	f7 f1                	div    %ecx
 6bd:	89 d1                	mov    %edx,%ecx
 6bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c2:	8d 50 01             	lea    0x1(%eax),%edx
 6c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6c8:	0f b6 91 80 0b 00 00 	movzbl 0xb80(%ecx),%edx
 6cf:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d9:	ba 00 00 00 00       	mov    $0x0,%edx
 6de:	f7 f1                	div    %ecx
 6e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e7:	75 c7                	jne    6b0 <printint+0x37>
  if(neg)
 6e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6ed:	74 2d                	je     71c <printint+0xa3>
    buf[i++] = '-';
 6ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f2:	8d 50 01             	lea    0x1(%eax),%edx
 6f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6fd:	eb 1d                	jmp    71c <printint+0xa3>
    putc(fd, buf[i]);
 6ff:	8d 55 dc             	lea    -0x24(%ebp),%edx
 702:	8b 45 f4             	mov    -0xc(%ebp),%eax
 705:	01 d0                	add    %edx,%eax
 707:	0f b6 00             	movzbl (%eax),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	83 ec 08             	sub    $0x8,%esp
 710:	50                   	push   %eax
 711:	ff 75 08             	pushl  0x8(%ebp)
 714:	e8 3d ff ff ff       	call   656 <putc>
 719:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 71c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 720:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 724:	79 d9                	jns    6ff <printint+0x86>
}
 726:	90                   	nop
 727:	c9                   	leave  
 728:	c3                   	ret    

00000729 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 729:	55                   	push   %ebp
 72a:	89 e5                	mov    %esp,%ebp
 72c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 72f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 736:	8d 45 0c             	lea    0xc(%ebp),%eax
 739:	83 c0 04             	add    $0x4,%eax
 73c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 73f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 746:	e9 59 01 00 00       	jmp    8a4 <printf+0x17b>
    c = fmt[i] & 0xff;
 74b:	8b 55 0c             	mov    0xc(%ebp),%edx
 74e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 751:	01 d0                	add    %edx,%eax
 753:	0f b6 00             	movzbl (%eax),%eax
 756:	0f be c0             	movsbl %al,%eax
 759:	25 ff 00 00 00       	and    $0xff,%eax
 75e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 761:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 765:	75 2c                	jne    793 <printf+0x6a>
      if(c == '%'){
 767:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 76b:	75 0c                	jne    779 <printf+0x50>
        state = '%';
 76d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 774:	e9 27 01 00 00       	jmp    8a0 <printf+0x177>
      } else {
        putc(fd, c);
 779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77c:	0f be c0             	movsbl %al,%eax
 77f:	83 ec 08             	sub    $0x8,%esp
 782:	50                   	push   %eax
 783:	ff 75 08             	pushl  0x8(%ebp)
 786:	e8 cb fe ff ff       	call   656 <putc>
 78b:	83 c4 10             	add    $0x10,%esp
 78e:	e9 0d 01 00 00       	jmp    8a0 <printf+0x177>
      }
    } else if(state == '%'){
 793:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 797:	0f 85 03 01 00 00    	jne    8a0 <printf+0x177>
      if(c == 'd'){
 79d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7a1:	75 1e                	jne    7c1 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	6a 01                	push   $0x1
 7aa:	6a 0a                	push   $0xa
 7ac:	50                   	push   %eax
 7ad:	ff 75 08             	pushl  0x8(%ebp)
 7b0:	e8 c4 fe ff ff       	call   679 <printint>
 7b5:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7bc:	e9 d8 00 00 00       	jmp    899 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7c1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7c5:	74 06                	je     7cd <printf+0xa4>
 7c7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7cb:	75 1e                	jne    7eb <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	6a 00                	push   $0x0
 7d4:	6a 10                	push   $0x10
 7d6:	50                   	push   %eax
 7d7:	ff 75 08             	pushl  0x8(%ebp)
 7da:	e8 9a fe ff ff       	call   679 <printint>
 7df:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e6:	e9 ae 00 00 00       	jmp    899 <printf+0x170>
      } else if(c == 's'){
 7eb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ef:	75 43                	jne    834 <printf+0x10b>
        s = (char*)*ap;
 7f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 801:	75 25                	jne    828 <printf+0xff>
          s = "(null)";
 803:	c7 45 f4 2b 09 00 00 	movl   $0x92b,-0xc(%ebp)
        while(*s != 0){
 80a:	eb 1c                	jmp    828 <printf+0xff>
          putc(fd, *s);
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	0f b6 00             	movzbl (%eax),%eax
 812:	0f be c0             	movsbl %al,%eax
 815:	83 ec 08             	sub    $0x8,%esp
 818:	50                   	push   %eax
 819:	ff 75 08             	pushl  0x8(%ebp)
 81c:	e8 35 fe ff ff       	call   656 <putc>
 821:	83 c4 10             	add    $0x10,%esp
          s++;
 824:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 828:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82b:	0f b6 00             	movzbl (%eax),%eax
 82e:	84 c0                	test   %al,%al
 830:	75 da                	jne    80c <printf+0xe3>
 832:	eb 65                	jmp    899 <printf+0x170>
        }
      } else if(c == 'c'){
 834:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 838:	75 1d                	jne    857 <printf+0x12e>
        putc(fd, *ap);
 83a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	0f be c0             	movsbl %al,%eax
 842:	83 ec 08             	sub    $0x8,%esp
 845:	50                   	push   %eax
 846:	ff 75 08             	pushl  0x8(%ebp)
 849:	e8 08 fe ff ff       	call   656 <putc>
 84e:	83 c4 10             	add    $0x10,%esp
        ap++;
 851:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 855:	eb 42                	jmp    899 <printf+0x170>
      } else if(c == '%'){
 857:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 85b:	75 17                	jne    874 <printf+0x14b>
        putc(fd, c);
 85d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 860:	0f be c0             	movsbl %al,%eax
 863:	83 ec 08             	sub    $0x8,%esp
 866:	50                   	push   %eax
 867:	ff 75 08             	pushl  0x8(%ebp)
 86a:	e8 e7 fd ff ff       	call   656 <putc>
 86f:	83 c4 10             	add    $0x10,%esp
 872:	eb 25                	jmp    899 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 874:	83 ec 08             	sub    $0x8,%esp
 877:	6a 25                	push   $0x25
 879:	ff 75 08             	pushl  0x8(%ebp)
 87c:	e8 d5 fd ff ff       	call   656 <putc>
 881:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 887:	0f be c0             	movsbl %al,%eax
 88a:	83 ec 08             	sub    $0x8,%esp
 88d:	50                   	push   %eax
 88e:	ff 75 08             	pushl  0x8(%ebp)
 891:	e8 c0 fd ff ff       	call   656 <putc>
 896:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 899:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8a0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a4:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8aa:	01 d0                	add    %edx,%eax
 8ac:	0f b6 00             	movzbl (%eax),%eax
 8af:	84 c0                	test   %al,%al
 8b1:	0f 85 94 fe ff ff    	jne    74b <printf+0x22>
    }
  }
}
 8b7:	90                   	nop
 8b8:	c9                   	leave  
 8b9:	c3                   	ret    
