
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <forkchild>:

#define DEPTH 3

void forktree(char *cur);

void forkchild(char *cur, char branch) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	88 45 e4             	mov    %al,-0x1c(%ebp)
  char nxt[DEPTH+1];

  if (strlen(cur) >= DEPTH)
   c:	83 ec 0c             	sub    $0xc,%esp
   f:	ff 75 08             	pushl  0x8(%ebp)
  12:	e8 0f 02 00 00       	call   226 <strlen>
  17:	83 c4 10             	add    $0x10,%esp
  1a:	83 f8 02             	cmp    $0x2,%eax
  1d:	77 60                	ja     7f <forkchild+0x7f>
    return;


  int idx = strlen(cur);
  1f:	83 ec 0c             	sub    $0xc,%esp
  22:	ff 75 08             	pushl  0x8(%ebp)
  25:	e8 fc 01 00 00       	call   226 <strlen>
  2a:	83 c4 10             	add    $0x10,%esp
  2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  strcpy(nxt, cur);
  30:	83 ec 08             	sub    $0x8,%esp
  33:	ff 75 08             	pushl  0x8(%ebp)
  36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  39:	50                   	push   %eax
  3a:	e8 78 01 00 00       	call   1b7 <strcpy>
  3f:	83 c4 10             	add    $0x10,%esp
  nxt[idx] = branch;
  42:	8d 55 f0             	lea    -0x10(%ebp),%edx
  45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  48:	01 c2                	add    %eax,%edx
  4a:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  4e:	88 02                	mov    %al,(%edx)
  nxt[idx+1] = '\0';
  50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  53:	83 c0 01             	add    $0x1,%eax
  56:	c6 44 05 f0 00       	movb   $0x0,-0x10(%ebp,%eax,1)
  if (fork() == 0) {
  5b:	e8 89 00 00 00       	call   e9 <fork>
  60:	85 c0                	test   %eax,%eax
  62:	75 14                	jne    78 <forkchild+0x78>
    forktree(nxt);
  64:	83 ec 0c             	sub    $0xc,%esp
  67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  6a:	50                   	push   %eax
  6b:	e8 12 00 00 00       	call   82 <forktree>
  70:	83 c4 10             	add    $0x10,%esp
    exit();
  73:	e8 79 00 00 00       	call   f1 <exit>
  } else {
    wait();
  78:	e8 7c 00 00 00       	call   f9 <wait>
  7d:	eb 01                	jmp    80 <forkchild+0x80>
    return;
  7f:	90                   	nop
  }
}
  80:	c9                   	leave  
  81:	c3                   	ret    

00000082 <forktree>:

void forktree(char *cur) {
  82:	55                   	push   %ebp
  83:	89 e5                	mov    %esp,%ebp
  85:	83 ec 08             	sub    $0x8,%esp
  printf(1,"%d: I am '%s'\n", getpid(), cur);
  88:	e8 e4 00 00 00       	call   171 <getpid>
  8d:	ff 75 08             	pushl  0x8(%ebp)
  90:	50                   	push   %eax
  91:	68 69 08 00 00       	push   $0x869
  96:	6a 01                	push   $0x1
  98:	e8 3b 06 00 00       	call   6d8 <printf>
  9d:	83 c4 10             	add    $0x10,%esp

  forkchild(cur, '0');
  a0:	83 ec 08             	sub    $0x8,%esp
  a3:	6a 30                	push   $0x30
  a5:	ff 75 08             	pushl  0x8(%ebp)
  a8:	e8 53 ff ff ff       	call   0 <forkchild>
  ad:	83 c4 10             	add    $0x10,%esp
  forkchild(cur, '1');
  b0:	83 ec 08             	sub    $0x8,%esp
  b3:	6a 31                	push   $0x31
  b5:	ff 75 08             	pushl  0x8(%ebp)
  b8:	e8 43 ff ff ff       	call   0 <forkchild>
  bd:	83 c4 10             	add    $0x10,%esp
}
  c0:	90                   	nop
  c1:	c9                   	leave  
  c2:	c3                   	ret    

000000c3 <main>:

  int
main(int argc, char **argv)
{
  c3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  c7:	83 e4 f0             	and    $0xfffffff0,%esp
  ca:	ff 71 fc             	pushl  -0x4(%ecx)
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	51                   	push   %ecx
  d1:	83 ec 04             	sub    $0x4,%esp
  forktree("");
  d4:	83 ec 0c             	sub    $0xc,%esp
  d7:	68 78 08 00 00       	push   $0x878
  dc:	e8 a1 ff ff ff       	call   82 <forktree>
  e1:	83 c4 10             	add    $0x10,%esp
  exit();
  e4:	e8 08 00 00 00       	call   f1 <exit>

000000e9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  e9:	b8 01 00 00 00       	mov    $0x1,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <exit>:
SYSCALL(exit)
  f1:	b8 02 00 00 00       	mov    $0x2,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <wait>:
SYSCALL(wait)
  f9:	b8 03 00 00 00       	mov    $0x3,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <pipe>:
SYSCALL(pipe)
 101:	b8 04 00 00 00       	mov    $0x4,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <read>:
SYSCALL(read)
 109:	b8 05 00 00 00       	mov    $0x5,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <write>:
SYSCALL(write)
 111:	b8 10 00 00 00       	mov    $0x10,%eax
 116:	cd 40                	int    $0x40
 118:	c3                   	ret    

00000119 <close>:
SYSCALL(close)
 119:	b8 15 00 00 00       	mov    $0x15,%eax
 11e:	cd 40                	int    $0x40
 120:	c3                   	ret    

00000121 <kill>:
SYSCALL(kill)
 121:	b8 06 00 00 00       	mov    $0x6,%eax
 126:	cd 40                	int    $0x40
 128:	c3                   	ret    

00000129 <exec>:
SYSCALL(exec)
 129:	b8 07 00 00 00       	mov    $0x7,%eax
 12e:	cd 40                	int    $0x40
 130:	c3                   	ret    

00000131 <open>:
SYSCALL(open)
 131:	b8 0f 00 00 00       	mov    $0xf,%eax
 136:	cd 40                	int    $0x40
 138:	c3                   	ret    

00000139 <mknod>:
SYSCALL(mknod)
 139:	b8 11 00 00 00       	mov    $0x11,%eax
 13e:	cd 40                	int    $0x40
 140:	c3                   	ret    

00000141 <unlink>:
SYSCALL(unlink)
 141:	b8 12 00 00 00       	mov    $0x12,%eax
 146:	cd 40                	int    $0x40
 148:	c3                   	ret    

00000149 <fstat>:
SYSCALL(fstat)
 149:	b8 08 00 00 00       	mov    $0x8,%eax
 14e:	cd 40                	int    $0x40
 150:	c3                   	ret    

00000151 <link>:
SYSCALL(link)
 151:	b8 13 00 00 00       	mov    $0x13,%eax
 156:	cd 40                	int    $0x40
 158:	c3                   	ret    

00000159 <mkdir>:
SYSCALL(mkdir)
 159:	b8 14 00 00 00       	mov    $0x14,%eax
 15e:	cd 40                	int    $0x40
 160:	c3                   	ret    

00000161 <chdir>:
SYSCALL(chdir)
 161:	b8 09 00 00 00       	mov    $0x9,%eax
 166:	cd 40                	int    $0x40
 168:	c3                   	ret    

00000169 <dup>:
SYSCALL(dup)
 169:	b8 0a 00 00 00       	mov    $0xa,%eax
 16e:	cd 40                	int    $0x40
 170:	c3                   	ret    

00000171 <getpid>:
SYSCALL(getpid)
 171:	b8 0b 00 00 00       	mov    $0xb,%eax
 176:	cd 40                	int    $0x40
 178:	c3                   	ret    

00000179 <sbrk>:
SYSCALL(sbrk)
 179:	b8 0c 00 00 00       	mov    $0xc,%eax
 17e:	cd 40                	int    $0x40
 180:	c3                   	ret    

00000181 <sleep>:
SYSCALL(sleep)
 181:	b8 0d 00 00 00       	mov    $0xd,%eax
 186:	cd 40                	int    $0x40
 188:	c3                   	ret    

00000189 <uptime>:
SYSCALL(uptime)
 189:	b8 0e 00 00 00       	mov    $0xe,%eax
 18e:	cd 40                	int    $0x40
 190:	c3                   	ret    

00000191 <stosb>:
  __asm__ volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
stosb(void *addr, int data, int cnt)
{
 191:	55                   	push   %ebp
 192:	89 e5                	mov    %esp,%ebp
 194:	57                   	push   %edi
 195:	53                   	push   %ebx
  __asm__ volatile("cld; rep stosb" :
 196:	8b 4d 08             	mov    0x8(%ebp),%ecx
 199:	8b 55 10             	mov    0x10(%ebp),%edx
 19c:	8b 45 0c             	mov    0xc(%ebp),%eax
 19f:	89 cb                	mov    %ecx,%ebx
 1a1:	89 df                	mov    %ebx,%edi
 1a3:	89 d1                	mov    %edx,%ecx
 1a5:	fc                   	cld    
 1a6:	f3 aa                	rep stos %al,%es:(%edi)
 1a8:	89 ca                	mov    %ecx,%edx
 1aa:	89 fb                	mov    %edi,%ebx
 1ac:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1af:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1b2:	90                   	nop
 1b3:	5b                   	pop    %ebx
 1b4:	5f                   	pop    %edi
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    

000001b7 <strcpy>:
#include "user.h"
#include "asm/x86.h"

char*
strcpy(char *s, const char *t)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1c3:	90                   	nop
 1c4:	8b 55 0c             	mov    0xc(%ebp),%edx
 1c7:	8d 42 01             	lea    0x1(%edx),%eax
 1ca:	89 45 0c             	mov    %eax,0xc(%ebp)
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	8d 48 01             	lea    0x1(%eax),%ecx
 1d3:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1d6:	0f b6 12             	movzbl (%edx),%edx
 1d9:	88 10                	mov    %dl,(%eax)
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	84 c0                	test   %al,%al
 1e0:	75 e2                	jne    1c4 <strcpy+0xd>
    ;
  return os;
 1e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ea:	eb 08                	jmp    1f4 <strcmp+0xd>
    p++, q++;
 1ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	0f b6 00             	movzbl (%eax),%eax
 1fa:	84 c0                	test   %al,%al
 1fc:	74 10                	je     20e <strcmp+0x27>
 1fe:	8b 45 08             	mov    0x8(%ebp),%eax
 201:	0f b6 10             	movzbl (%eax),%edx
 204:	8b 45 0c             	mov    0xc(%ebp),%eax
 207:	0f b6 00             	movzbl (%eax),%eax
 20a:	38 c2                	cmp    %al,%dl
 20c:	74 de                	je     1ec <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	0f b6 00             	movzbl (%eax),%eax
 214:	0f b6 d0             	movzbl %al,%edx
 217:	8b 45 0c             	mov    0xc(%ebp),%eax
 21a:	0f b6 00             	movzbl (%eax),%eax
 21d:	0f b6 c0             	movzbl %al,%eax
 220:	29 c2                	sub    %eax,%edx
 222:	89 d0                	mov    %edx,%eax
}
 224:	5d                   	pop    %ebp
 225:	c3                   	ret    

00000226 <strlen>:

uint
strlen(const char *s)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 22c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 233:	eb 04                	jmp    239 <strlen+0x13>
 235:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 239:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	01 d0                	add    %edx,%eax
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	84 c0                	test   %al,%al
 246:	75 ed                	jne    235 <strlen+0xf>
    ;
  return n;
 248:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <memset>:

void*
memset(void *dst, int c, uint n)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 250:	8b 45 10             	mov    0x10(%ebp),%eax
 253:	50                   	push   %eax
 254:	ff 75 0c             	pushl  0xc(%ebp)
 257:	ff 75 08             	pushl  0x8(%ebp)
 25a:	e8 32 ff ff ff       	call   191 <stosb>
 25f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 262:	8b 45 08             	mov    0x8(%ebp),%eax
}
 265:	c9                   	leave  
 266:	c3                   	ret    

00000267 <strchr>:

char*
strchr(const char *s, char c)
{
 267:	55                   	push   %ebp
 268:	89 e5                	mov    %esp,%ebp
 26a:	83 ec 04             	sub    $0x4,%esp
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 273:	eb 14                	jmp    289 <strchr+0x22>
    if(*s == c)
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	38 45 fc             	cmp    %al,-0x4(%ebp)
 27e:	75 05                	jne    285 <strchr+0x1e>
      return (char*)s;
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	eb 13                	jmp    298 <strchr+0x31>
  for(; *s; s++)
 285:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	0f b6 00             	movzbl (%eax),%eax
 28f:	84 c0                	test   %al,%al
 291:	75 e2                	jne    275 <strchr+0xe>
  return 0;
 293:	b8 00 00 00 00       	mov    $0x0,%eax
}
 298:	c9                   	leave  
 299:	c3                   	ret    

0000029a <gets>:

char*
gets(char *buf, int max)
{
 29a:	55                   	push   %ebp
 29b:	89 e5                	mov    %esp,%ebp
 29d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2a7:	eb 42                	jmp    2eb <gets+0x51>
    cc = read(0, &c, 1);
 2a9:	83 ec 04             	sub    $0x4,%esp
 2ac:	6a 01                	push   $0x1
 2ae:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2b1:	50                   	push   %eax
 2b2:	6a 00                	push   $0x0
 2b4:	e8 50 fe ff ff       	call   109 <read>
 2b9:	83 c4 10             	add    $0x10,%esp
 2bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2c3:	7e 33                	jle    2f8 <gets+0x5e>
      break;
    buf[i++] = c;
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	8d 50 01             	lea    0x1(%eax),%edx
 2cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2ce:	89 c2                	mov    %eax,%edx
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	01 c2                	add    %eax,%edx
 2d5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2d9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2df:	3c 0a                	cmp    $0xa,%al
 2e1:	74 16                	je     2f9 <gets+0x5f>
 2e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e7:	3c 0d                	cmp    $0xd,%al
 2e9:	74 0e                	je     2f9 <gets+0x5f>
  for(i=0; i+1 < max; ){
 2eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ee:	83 c0 01             	add    $0x1,%eax
 2f1:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2f4:	7f b3                	jg     2a9 <gets+0xf>
 2f6:	eb 01                	jmp    2f9 <gets+0x5f>
      break;
 2f8:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	01 d0                	add    %edx,%eax
 301:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 304:	8b 45 08             	mov    0x8(%ebp),%eax
}
 307:	c9                   	leave  
 308:	c3                   	ret    

00000309 <stat>:

int
stat(const char *n, struct stat *st)
{
 309:	55                   	push   %ebp
 30a:	89 e5                	mov    %esp,%ebp
 30c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30f:	83 ec 08             	sub    $0x8,%esp
 312:	6a 00                	push   $0x0
 314:	ff 75 08             	pushl  0x8(%ebp)
 317:	e8 15 fe ff ff       	call   131 <open>
 31c:	83 c4 10             	add    $0x10,%esp
 31f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 326:	79 07                	jns    32f <stat+0x26>
    return -1;
 328:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 32d:	eb 25                	jmp    354 <stat+0x4b>
  r = fstat(fd, st);
 32f:	83 ec 08             	sub    $0x8,%esp
 332:	ff 75 0c             	pushl  0xc(%ebp)
 335:	ff 75 f4             	pushl  -0xc(%ebp)
 338:	e8 0c fe ff ff       	call   149 <fstat>
 33d:	83 c4 10             	add    $0x10,%esp
 340:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 343:	83 ec 0c             	sub    $0xc,%esp
 346:	ff 75 f4             	pushl  -0xc(%ebp)
 349:	e8 cb fd ff ff       	call   119 <close>
 34e:	83 c4 10             	add    $0x10,%esp
  return r;
 351:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 354:	c9                   	leave  
 355:	c3                   	ret    

00000356 <atoi>:

int
atoi(const char *s)
{
 356:	55                   	push   %ebp
 357:	89 e5                	mov    %esp,%ebp
 359:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 35c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 363:	eb 25                	jmp    38a <atoi+0x34>
    n = n*10 + *s++ - '0';
 365:	8b 55 fc             	mov    -0x4(%ebp),%edx
 368:	89 d0                	mov    %edx,%eax
 36a:	c1 e0 02             	shl    $0x2,%eax
 36d:	01 d0                	add    %edx,%eax
 36f:	01 c0                	add    %eax,%eax
 371:	89 c1                	mov    %eax,%ecx
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	8d 50 01             	lea    0x1(%eax),%edx
 379:	89 55 08             	mov    %edx,0x8(%ebp)
 37c:	0f b6 00             	movzbl (%eax),%eax
 37f:	0f be c0             	movsbl %al,%eax
 382:	01 c8                	add    %ecx,%eax
 384:	83 e8 30             	sub    $0x30,%eax
 387:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
 38d:	0f b6 00             	movzbl (%eax),%eax
 390:	3c 2f                	cmp    $0x2f,%al
 392:	7e 0a                	jle    39e <atoi+0x48>
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	0f b6 00             	movzbl (%eax),%eax
 39a:	3c 39                	cmp    $0x39,%al
 39c:	7e c7                	jle    365 <atoi+0xf>
  return n;
 39e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a1:	c9                   	leave  
 3a2:	c3                   	ret    

000003a3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a3:	55                   	push   %ebp
 3a4:	89 e5                	mov    %esp,%ebp
 3a6:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3af:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3b5:	eb 17                	jmp    3ce <memmove+0x2b>
    *dst++ = *src++;
 3b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ba:	8d 42 01             	lea    0x1(%edx),%eax
 3bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3c3:	8d 48 01             	lea    0x1(%eax),%ecx
 3c6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3c9:	0f b6 12             	movzbl (%edx),%edx
 3cc:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3ce:	8b 45 10             	mov    0x10(%ebp),%eax
 3d1:	8d 50 ff             	lea    -0x1(%eax),%edx
 3d4:	89 55 10             	mov    %edx,0x10(%ebp)
 3d7:	85 c0                	test   %eax,%eax
 3d9:	7f dc                	jg     3b7 <memmove+0x14>
  return vdst;
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	83 e8 08             	sub    $0x8,%eax
 3ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 3ef:	a1 20 0b 00 00       	mov    0xb20,%eax
 3f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3f7:	eb 24                	jmp    41d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 3f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3fc:	8b 00                	mov    (%eax),%eax
 3fe:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 401:	72 12                	jb     415 <free+0x35>
 403:	8b 45 f8             	mov    -0x8(%ebp),%eax
 406:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 409:	77 24                	ja     42f <free+0x4f>
 40b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40e:	8b 00                	mov    (%eax),%eax
 410:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 413:	72 1a                	jb     42f <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 415:	8b 45 fc             	mov    -0x4(%ebp),%eax
 418:	8b 00                	mov    (%eax),%eax
 41a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 41d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 420:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 423:	76 d4                	jbe    3f9 <free+0x19>
 425:	8b 45 fc             	mov    -0x4(%ebp),%eax
 428:	8b 00                	mov    (%eax),%eax
 42a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 42d:	73 ca                	jae    3f9 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 42f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 432:	8b 40 04             	mov    0x4(%eax),%eax
 435:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 43c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 43f:	01 c2                	add    %eax,%edx
 441:	8b 45 fc             	mov    -0x4(%ebp),%eax
 444:	8b 00                	mov    (%eax),%eax
 446:	39 c2                	cmp    %eax,%edx
 448:	75 24                	jne    46e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 44a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 44d:	8b 50 04             	mov    0x4(%eax),%edx
 450:	8b 45 fc             	mov    -0x4(%ebp),%eax
 453:	8b 00                	mov    (%eax),%eax
 455:	8b 40 04             	mov    0x4(%eax),%eax
 458:	01 c2                	add    %eax,%edx
 45a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 45d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 460:	8b 45 fc             	mov    -0x4(%ebp),%eax
 463:	8b 00                	mov    (%eax),%eax
 465:	8b 10                	mov    (%eax),%edx
 467:	8b 45 f8             	mov    -0x8(%ebp),%eax
 46a:	89 10                	mov    %edx,(%eax)
 46c:	eb 0a                	jmp    478 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 46e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 471:	8b 10                	mov    (%eax),%edx
 473:	8b 45 f8             	mov    -0x8(%ebp),%eax
 476:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 478:	8b 45 fc             	mov    -0x4(%ebp),%eax
 47b:	8b 40 04             	mov    0x4(%eax),%eax
 47e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 485:	8b 45 fc             	mov    -0x4(%ebp),%eax
 488:	01 d0                	add    %edx,%eax
 48a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 48d:	75 20                	jne    4af <free+0xcf>
    p->s.size += bp->s.size;
 48f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 492:	8b 50 04             	mov    0x4(%eax),%edx
 495:	8b 45 f8             	mov    -0x8(%ebp),%eax
 498:	8b 40 04             	mov    0x4(%eax),%eax
 49b:	01 c2                	add    %eax,%edx
 49d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4a0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4a6:	8b 10                	mov    (%eax),%edx
 4a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ab:	89 10                	mov    %edx,(%eax)
 4ad:	eb 08                	jmp    4b7 <free+0xd7>
  } else
    p->s.ptr = bp;
 4af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4b5:	89 10                	mov    %edx,(%eax)
  freep = p;
 4b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ba:	a3 20 0b 00 00       	mov    %eax,0xb20
}
 4bf:	90                   	nop
 4c0:	c9                   	leave  
 4c1:	c3                   	ret    

000004c2 <morecore>:

static Header*
morecore(uint nu)
{
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp
 4c5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 4c8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 4cf:	77 07                	ja     4d8 <morecore+0x16>
    nu = 4096;
 4d1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
 4db:	c1 e0 03             	shl    $0x3,%eax
 4de:	83 ec 0c             	sub    $0xc,%esp
 4e1:	50                   	push   %eax
 4e2:	e8 92 fc ff ff       	call   179 <sbrk>
 4e7:	83 c4 10             	add    $0x10,%esp
 4ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 4ed:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 4f1:	75 07                	jne    4fa <morecore+0x38>
    return 0;
 4f3:	b8 00 00 00 00       	mov    $0x0,%eax
 4f8:	eb 26                	jmp    520 <morecore+0x5e>
  hp = (Header*)p;
 4fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 500:	8b 45 f0             	mov    -0x10(%ebp),%eax
 503:	8b 55 08             	mov    0x8(%ebp),%edx
 506:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 509:	8b 45 f0             	mov    -0x10(%ebp),%eax
 50c:	83 c0 08             	add    $0x8,%eax
 50f:	83 ec 0c             	sub    $0xc,%esp
 512:	50                   	push   %eax
 513:	e8 c8 fe ff ff       	call   3e0 <free>
 518:	83 c4 10             	add    $0x10,%esp
  return freep;
 51b:	a1 20 0b 00 00       	mov    0xb20,%eax
}
 520:	c9                   	leave  
 521:	c3                   	ret    

00000522 <malloc>:

void*
malloc(uint nbytes)
{
 522:	55                   	push   %ebp
 523:	89 e5                	mov    %esp,%ebp
 525:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 528:	8b 45 08             	mov    0x8(%ebp),%eax
 52b:	83 c0 07             	add    $0x7,%eax
 52e:	c1 e8 03             	shr    $0x3,%eax
 531:	83 c0 01             	add    $0x1,%eax
 534:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 537:	a1 20 0b 00 00       	mov    0xb20,%eax
 53c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 53f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 543:	75 23                	jne    568 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 545:	c7 45 f0 18 0b 00 00 	movl   $0xb18,-0x10(%ebp)
 54c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 54f:	a3 20 0b 00 00       	mov    %eax,0xb20
 554:	a1 20 0b 00 00       	mov    0xb20,%eax
 559:	a3 18 0b 00 00       	mov    %eax,0xb18
    base.s.size = 0;
 55e:	c7 05 1c 0b 00 00 00 	movl   $0x0,0xb1c
 565:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 568:	8b 45 f0             	mov    -0x10(%ebp),%eax
 56b:	8b 00                	mov    (%eax),%eax
 56d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 570:	8b 45 f4             	mov    -0xc(%ebp),%eax
 573:	8b 40 04             	mov    0x4(%eax),%eax
 576:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 579:	77 4d                	ja     5c8 <malloc+0xa6>
      if(p->s.size == nunits)
 57b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57e:	8b 40 04             	mov    0x4(%eax),%eax
 581:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 584:	75 0c                	jne    592 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 586:	8b 45 f4             	mov    -0xc(%ebp),%eax
 589:	8b 10                	mov    (%eax),%edx
 58b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 58e:	89 10                	mov    %edx,(%eax)
 590:	eb 26                	jmp    5b8 <malloc+0x96>
      else {
        p->s.size -= nunits;
 592:	8b 45 f4             	mov    -0xc(%ebp),%eax
 595:	8b 40 04             	mov    0x4(%eax),%eax
 598:	2b 45 ec             	sub    -0x14(%ebp),%eax
 59b:	89 c2                	mov    %eax,%edx
 59d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a0:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a6:	8b 40 04             	mov    0x4(%eax),%eax
 5a9:	c1 e0 03             	shl    $0x3,%eax
 5ac:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
 5b5:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 5b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5bb:	a3 20 0b 00 00       	mov    %eax,0xb20
      return (void*)(p + 1);
 5c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c3:	83 c0 08             	add    $0x8,%eax
 5c6:	eb 3b                	jmp    603 <malloc+0xe1>
    }
    if(p == freep)
 5c8:	a1 20 0b 00 00       	mov    0xb20,%eax
 5cd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 5d0:	75 1e                	jne    5f0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 5d2:	83 ec 0c             	sub    $0xc,%esp
 5d5:	ff 75 ec             	pushl  -0x14(%ebp)
 5d8:	e8 e5 fe ff ff       	call   4c2 <morecore>
 5dd:	83 c4 10             	add    $0x10,%esp
 5e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e7:	75 07                	jne    5f0 <malloc+0xce>
        return 0;
 5e9:	b8 00 00 00 00       	mov    $0x0,%eax
 5ee:	eb 13                	jmp    603 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 5f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f9:	8b 00                	mov    (%eax),%eax
 5fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 5fe:	e9 6d ff ff ff       	jmp    570 <malloc+0x4e>
  }
}
 603:	c9                   	leave  
 604:	c3                   	ret    

00000605 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 605:	55                   	push   %ebp
 606:	89 e5                	mov    %esp,%ebp
 608:	83 ec 18             	sub    $0x18,%esp
 60b:	8b 45 0c             	mov    0xc(%ebp),%eax
 60e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 611:	83 ec 04             	sub    $0x4,%esp
 614:	6a 01                	push   $0x1
 616:	8d 45 f4             	lea    -0xc(%ebp),%eax
 619:	50                   	push   %eax
 61a:	ff 75 08             	pushl  0x8(%ebp)
 61d:	e8 ef fa ff ff       	call   111 <write>
 622:	83 c4 10             	add    $0x10,%esp
}
 625:	90                   	nop
 626:	c9                   	leave  
 627:	c3                   	ret    

00000628 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 62e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 635:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 639:	74 17                	je     652 <printint+0x2a>
 63b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 63f:	79 11                	jns    652 <printint+0x2a>
    neg = 1;
 641:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	f7 d8                	neg    %eax
 64d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 650:	eb 06                	jmp    658 <printint+0x30>
  } else {
    x = xx;
 652:	8b 45 0c             	mov    0xc(%ebp),%eax
 655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 65f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 662:	8b 45 ec             	mov    -0x14(%ebp),%eax
 665:	ba 00 00 00 00       	mov    $0x0,%edx
 66a:	f7 f1                	div    %ecx
 66c:	89 d1                	mov    %edx,%ecx
 66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 671:	8d 50 01             	lea    0x1(%eax),%edx
 674:	89 55 f4             	mov    %edx,-0xc(%ebp)
 677:	0f b6 91 04 0b 00 00 	movzbl 0xb04(%ecx),%edx
 67e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 682:	8b 4d 10             	mov    0x10(%ebp),%ecx
 685:	8b 45 ec             	mov    -0x14(%ebp),%eax
 688:	ba 00 00 00 00       	mov    $0x0,%edx
 68d:	f7 f1                	div    %ecx
 68f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 692:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 696:	75 c7                	jne    65f <printint+0x37>
  if(neg)
 698:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 69c:	74 2d                	je     6cb <printint+0xa3>
    buf[i++] = '-';
 69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a1:	8d 50 01             	lea    0x1(%eax),%edx
 6a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6ac:	eb 1d                	jmp    6cb <printint+0xa3>
    putc(fd, buf[i]);
 6ae:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b4:	01 d0                	add    %edx,%eax
 6b6:	0f b6 00             	movzbl (%eax),%eax
 6b9:	0f be c0             	movsbl %al,%eax
 6bc:	83 ec 08             	sub    $0x8,%esp
 6bf:	50                   	push   %eax
 6c0:	ff 75 08             	pushl  0x8(%ebp)
 6c3:	e8 3d ff ff ff       	call   605 <putc>
 6c8:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6cb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d3:	79 d9                	jns    6ae <printint+0x86>
}
 6d5:	90                   	nop
 6d6:	c9                   	leave  
 6d7:	c3                   	ret    

000006d8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 6d8:	55                   	push   %ebp
 6d9:	89 e5                	mov    %esp,%ebp
 6db:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6e5:	8d 45 0c             	lea    0xc(%ebp),%eax
 6e8:	83 c0 04             	add    $0x4,%eax
 6eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6f5:	e9 59 01 00 00       	jmp    853 <printf+0x17b>
    c = fmt[i] & 0xff;
 6fa:	8b 55 0c             	mov    0xc(%ebp),%edx
 6fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 700:	01 d0                	add    %edx,%eax
 702:	0f b6 00             	movzbl (%eax),%eax
 705:	0f be c0             	movsbl %al,%eax
 708:	25 ff 00 00 00       	and    $0xff,%eax
 70d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 710:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 714:	75 2c                	jne    742 <printf+0x6a>
      if(c == '%'){
 716:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71a:	75 0c                	jne    728 <printf+0x50>
        state = '%';
 71c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 723:	e9 27 01 00 00       	jmp    84f <printf+0x177>
      } else {
        putc(fd, c);
 728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72b:	0f be c0             	movsbl %al,%eax
 72e:	83 ec 08             	sub    $0x8,%esp
 731:	50                   	push   %eax
 732:	ff 75 08             	pushl  0x8(%ebp)
 735:	e8 cb fe ff ff       	call   605 <putc>
 73a:	83 c4 10             	add    $0x10,%esp
 73d:	e9 0d 01 00 00       	jmp    84f <printf+0x177>
      }
    } else if(state == '%'){
 742:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 746:	0f 85 03 01 00 00    	jne    84f <printf+0x177>
      if(c == 'd'){
 74c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 750:	75 1e                	jne    770 <printf+0x98>
        printint(fd, *ap, 10, 1);
 752:	8b 45 e8             	mov    -0x18(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	6a 01                	push   $0x1
 759:	6a 0a                	push   $0xa
 75b:	50                   	push   %eax
 75c:	ff 75 08             	pushl  0x8(%ebp)
 75f:	e8 c4 fe ff ff       	call   628 <printint>
 764:	83 c4 10             	add    $0x10,%esp
        ap++;
 767:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76b:	e9 d8 00 00 00       	jmp    848 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 770:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 774:	74 06                	je     77c <printf+0xa4>
 776:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 77a:	75 1e                	jne    79a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 77c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77f:	8b 00                	mov    (%eax),%eax
 781:	6a 00                	push   $0x0
 783:	6a 10                	push   $0x10
 785:	50                   	push   %eax
 786:	ff 75 08             	pushl  0x8(%ebp)
 789:	e8 9a fe ff ff       	call   628 <printint>
 78e:	83 c4 10             	add    $0x10,%esp
        ap++;
 791:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 795:	e9 ae 00 00 00       	jmp    848 <printf+0x170>
      } else if(c == 's'){
 79a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 79e:	75 43                	jne    7e3 <printf+0x10b>
        s = (char*)*ap;
 7a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a3:	8b 00                	mov    (%eax),%eax
 7a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b0:	75 25                	jne    7d7 <printf+0xff>
          s = "(null)";
 7b2:	c7 45 f4 79 08 00 00 	movl   $0x879,-0xc(%ebp)
        while(*s != 0){
 7b9:	eb 1c                	jmp    7d7 <printf+0xff>
          putc(fd, *s);
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	0f b6 00             	movzbl (%eax),%eax
 7c1:	0f be c0             	movsbl %al,%eax
 7c4:	83 ec 08             	sub    $0x8,%esp
 7c7:	50                   	push   %eax
 7c8:	ff 75 08             	pushl  0x8(%ebp)
 7cb:	e8 35 fe ff ff       	call   605 <putc>
 7d0:	83 c4 10             	add    $0x10,%esp
          s++;
 7d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	0f b6 00             	movzbl (%eax),%eax
 7dd:	84 c0                	test   %al,%al
 7df:	75 da                	jne    7bb <printf+0xe3>
 7e1:	eb 65                	jmp    848 <printf+0x170>
        }
      } else if(c == 'c'){
 7e3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7e7:	75 1d                	jne    806 <printf+0x12e>
        putc(fd, *ap);
 7e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	0f be c0             	movsbl %al,%eax
 7f1:	83 ec 08             	sub    $0x8,%esp
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	pushl  0x8(%ebp)
 7f8:	e8 08 fe ff ff       	call   605 <putc>
 7fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 800:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 804:	eb 42                	jmp    848 <printf+0x170>
      } else if(c == '%'){
 806:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 80a:	75 17                	jne    823 <printf+0x14b>
        putc(fd, c);
 80c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80f:	0f be c0             	movsbl %al,%eax
 812:	83 ec 08             	sub    $0x8,%esp
 815:	50                   	push   %eax
 816:	ff 75 08             	pushl  0x8(%ebp)
 819:	e8 e7 fd ff ff       	call   605 <putc>
 81e:	83 c4 10             	add    $0x10,%esp
 821:	eb 25                	jmp    848 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 823:	83 ec 08             	sub    $0x8,%esp
 826:	6a 25                	push   $0x25
 828:	ff 75 08             	pushl  0x8(%ebp)
 82b:	e8 d5 fd ff ff       	call   605 <putc>
 830:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 833:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 836:	0f be c0             	movsbl %al,%eax
 839:	83 ec 08             	sub    $0x8,%esp
 83c:	50                   	push   %eax
 83d:	ff 75 08             	pushl  0x8(%ebp)
 840:	e8 c0 fd ff ff       	call   605 <putc>
 845:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 848:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 84f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 853:	8b 55 0c             	mov    0xc(%ebp),%edx
 856:	8b 45 f0             	mov    -0x10(%ebp),%eax
 859:	01 d0                	add    %edx,%eax
 85b:	0f b6 00             	movzbl (%eax),%eax
 85e:	84 c0                	test   %al,%al
 860:	0f 85 94 fe ff ff    	jne    6fa <printf+0x22>
    }
  }
}
 866:	90                   	nop
 867:	c9                   	leave  
 868:	c3                   	ret    
