# Lab 4 -- User-Isolation and File Permissions

The purpose of this lab is to have you explore how the kernel can enable
user-space applications to build their own isolation and login systems through
simple, minimal, low-level kernel interfaces.  To accomplish this you will
create a simple, but realistic user system for xv6, and a file permission system
for the xv6 filesystem.

With these primitives you may build an actual user-space login system (much like
a Linux Distro's login system), and we encourage you to play around with this
idea (although we're not requiring it as part of the lab work).

NOTE: For simplicity, and to avoid autograder build failures, your lab4 branch
should have the user-space component for all new system-calls added in this lab.
When implementing a new system call you will only need to implement the
kernel-side component of the call.

## Part 1 -- Adding Users

In the first portion of this lab you will be providing each process with a
logical user identifer (henceforth `uid`).  There will be two functions which
allow a user-space process within xv6 to modify or view the current uid `uid`:

```c
/**
 * Sets the uid of the current process
 * @argument uid -- The uid to change to.  Valid ranges are 0x0-0xFFFF
 *
 * @returns 0 on success -1 on failure
 */
int setuid(int);
```

and

```c
/**
 * Gets the uid of the currently running process.
 *
 * @returns The current process's uid.
 */
int getuid(void);
```

Beyond this description the following rules should be applied for uids:
- The uid of `init` is 0.
- Each child process inherits its parent's `uid`
- Only processes with `uid` 0 may change their `uid` through `setuid`


## Part 2 -- File Permissions

Now that you have a basic user identifier system working, you'll be adding file
permissions to the system which leverage the `uid` system to logically isolate
certain files.

To accomplish this, you will add several properties to each file and directory
within xv6.  First, the `owner` field will determine which uid `owns` a specific
file.  Second, the `permission` field will determine the access privleges
non-owners have for a specific file.

### Logical Permissions

The permission system logically works in the following way:
- If a file is accessed by its owner or `uid` 0 (henceforth `root`), then that
  access is permitted
- If the file is accessed for reading by another user (not its owner or root)
  and its read permission is set, that access is permitted
- If the file is accessed for writing by another user (not its owner or root)
  and its write permission is set, that access is permitted
- All other accesses are not permitted.

Operations which are considered file accesses (and their acess types) are:
- directory reads (read)
- exec (read)
- open (read and/or write, depending on flags)
- file creation/removal (write to file's directory)
- stat (read)

If an operation is not permitted, the system call should return -1, and no 
changes to the disk or file-system state should occur.  If the operation is
permitted, the operation should occur as they did before the permission system
was added.

**NIT**: Directory reads include the "path walk" a filesystem does to open a file in
a nested directory.

By default, all newly created files should be owned by the process that created the file,
and have `PROT_R` and `PROT_W` both cleared.

### System Call Interface

To control the permissions of a file, you'll be adding two new system calls
to the xv6 filesystem:

```c
/**
 * Changes the owner of the file at filename to uid. Returns 0 if
 * successful, and -1 on failure (on failure no permissions are changed).
 *
 * @arg filename -- A filesystem path naming the file to change
 * @arg uid -- The new owner of the file, valid range is 0x0-0xFFFF
 * 
 * @returns 0 on success, -1 on failure
 */

int chown(const char *filename, int uid);
```

And 

```c
/**
 * Changes the permissions of the file at filename to perm.  Returns 0 if
 * successful, and -1 on failure (on failure no permissions are changed).
 *
 * @arg filename -- A filesystem path naming the file to change
 * @arg perm -- The new permissions for the file.
 * 
 * @returns 0 on success, -1 on failure.
 */

int chmod(const char *filename, int perm);
```

Here a filesystem path refers to either a relative path (e.g. "testdir/file1") or
an absolute path (e.g. "/home/ddevec/testdir/file1").

Both of these system calls change the file's `owner` and `permission` properties
respectively.  The permission flags used by `chmod` are `PROT_W` and `PROT_R` as
defined in `include/fs.h`.

Additionally, the following rules should apply to chmod and chown:
- If an invalid uid is passed to `chown`, chown will fail.
- Only a file's owner or root may successfully change a file's permission or
  owner.  All attempts by other users should fail with a return code of -1.
- Any changes to a files permission or owner are expected to persist on restart.

### Physical Disk Layout Requirements

All changes to file ownership or permissions should be atomically persisted to
disk (using xv6's log will be sufficient for this).

To facilitate grading, we require a specific physical disk layout for our files.
In particular, the on-disk layout of the file's inode must be:

```
+0x00 - 2bytes - type  -- file type
+0x02 - 2bytes - major -- major device number
+0x04 - 2bytes - minor -- minor device number
+0x06 - 2bytes - nlink -- number of links to inode in the file system
+0x08 - 4bytes - size  -- size of the file in bytes
+0x0c - 2bytes - owner -- Owner uid of the file
+0x0e - 2bytes - perms -- Permissions of the file
+0x10 - 48bytes - addres -- Array of data block addresses + indirect block address
```

Additionally, the following requirements must be followed for all file system
operations:
- Operations must persist across reboots
- All filesystem operations (including `chown` and `chmod`) must be presistent
  and atomic.  We recommend exploring xv6's `log` infrastructure to achieve
  atomic persistent filesystem operations in xv6 (and associated video).

NOTE: You will have to modify mkfs (`tools/mkfs.c`) to support your new
filesystem inode layout.  You should modify it to default all files as being
owned by root and having both the read and write permission bits set.

