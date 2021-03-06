# Autograder Manual

The purpose of this document is to outline the functionality, use, and rules of
the cs3210 autograder.

In cs3210 this semester we will be using an interactive autograder to help
evaluate your lab solutions.  The autograder will download your submissions from
[GaTech's GitHub](https://github.gatech.edu), and then run a series of tests on
your code, delivering the results to you as it runs (usually).  

The goal of the autograder is to help you ensure you've implemented the project
correctly, and have a good idea of the credit you will receive.  It is not
intended for debugging your project, and will not deliver particularly useful
feedback (it will only tell you if you pass or fail a test, not what that test
was, or why you failed).

## Autograder Policies

The autograder is intended to help you throughout this course, and give you some
confidence as to where you stand with your lab submissions.  However, the
autograder doesn't have infinite resources, and needs to ensure submissions are
kept safe.  As a result, the autograder has several specific policies it will
require you to adhere to.

### Feedback Submissions

If students were to all submit their lab frequently (and last minute), the
autograder queue would become very long, potentially causing students to wait
many hours before their submission is graded, resulting in poor grades and late
submissions.  This issue is caused by students attempting to use the autograder
as a last-minute debugging tool instead of its true intention -- an automatic
grading and feedback mechanism.  To help alleviate this issue, the autograder
will only provide students with a limited amount of feedback per day by limiting
the number of submissions it provides feedback for.

To be more precise, when you run the autograder with a feedback-enabled
submission, the autograder will tell you what test number it's running, if you
passed that test, then ultimately the total number of tests you've passed.  This
will give you a good idea of how well your submission did.  Once you've expended
all of your available feedback enabled submissions, the autograder will only
tell you that it has run your submission, and provide no graded feedback.

The policy on feedback-enabled submissions is that students get one-per-day
(a day starts at midnight, and ends at midnight).  These "feedbacks" cannot be
stockpiled (it goes away at midnight).  However, we understand that sometimes
students are working hard and don't want to wait until the next day to submit,
so we provide 3 extra graded feedbacks per project, which the student may use at
any point in place of a non-feedback submission (e.g. at your 2nd+ submission
for that day).  These extra feedbacks do not transition between projects.

### Malicious Submissions

All submissions to the autograder will be logged both locally (on the
autograder) and remotely (off the autograder), and may be audited.  Any
unauthorized attempt to subvert the autograder, either by gaining control of the
autograder machine, exposing autograder testcases, or generally using the
autograder for any purpose other than its intended one (to grade your code),
will be considered a violation of Georgia Tech's honor code and will be
severely punished.  The autograder has many safety checks and fail-safes in
place.  Do not attempt to attack the autograder!

### Autograder-Specific Requirements

The autograder does place some specific restrictions on how you modify your
code and construct your labs.  You may add any source files you like to the
bootloader, kernel, or user files, but the autograder will not respect any
changes to CMakeLists.txt (that would allow students to run arbitrary code).
Instead, you must specify any changes in the list within the Sources.cmake
directory.

Additionally, the autograder will ignore any changes made to any of the scripts
run to create the kernel.  The files the autograder will ignore or overwrite
includes:

- CMakeLists.txt
- user/CMakeLists.txt
- kernel/CMakeLists.txt
- bootblock/CMakeLists.txt
- tools/CMakeLists.txt
- scripts/xv6-qemu
- tools/mkfs
- tools/cuth
- tools/printpcs
- tools/pr.pl
- tools/runoff
- tools/runoff1
- tools/runoff.list
- tools/runoff.spec
- tools/show1
- tools/spinp
- tools/toc.ftr
- tools/toc.hdr
- kernel/tools/mksym.sh
- kernel/tools/vectors.pl

Furthermore, the autograder restricts the changes you are allowed to make to your
Sources.cmake (`kernel/Sources.cmake`, `user/Sources.cmake`, and
`bootblock/Sources.cmake`).  You are only allowed to modify the lists present in
those files.

You **may not** add any autograder generated files (e.g. anything in the `build` directory,
or any files generated by `cmake` to your git repository.  Doing so will likely cause an autograder
error, wasting your submission.

Finally, when the autograder runs your code, it will do so in Release mode (with
the option `-DCMAKE_BUILD_TYPE=Release`).  Ensure your code works in Release
mode before submitting it to the autograder!

### Misc Autograder Rules

- You may only have one submission queued at a time (if you have a submission
  queued, but not yet graded, the autograder will reject additional submission
  requests until your submission is graded).
- You may not modify the transition interface between the bootblock and the kernel.
  Doing so may cause the autograder to crash when booting your kernel.


## Autograder Use

To use the autograder, visit the [autograder page][autograder], and click the
authenticate button.  NOTE: You'll have to be logged into the campus VPN to access
it.  This will bring you to a GitHub login page, where you will
give the autograder permission to know your identity and checkout your private
repositories.  Once you've completed the authentication, you will be taken back
to the autograder, where the autograder will display the available labs.  From
here the operation of the autograder should be mostly self-explanatory.  We'll
outline a few important details about lab submission now.

### Submission Confirmation

Once you choose to submit your lab, the autograder will show you a confirmation
page, containing a series of information looking somewhat like this:

```
Grade request for lab: lab1
Request has locked in timestamp: 06-23-2020 11:43

github commit hash to be graded: d6f55858a1945baaf1e1925eddbf8fe29dc3fe14
Your request will do the following:
Original Due Date (before late days): 09-02-2020 23:59
Previous Due Date (after previously applied late days): 09-02-2020 23:59
New Due Date (after late days applied for this request): 09-02-2020 23:59
Late Days applied for this request: 0
Late Penalty (if you're out of late days): 0%
Late Days remaining: 3

Feedback Given: True
Extra Feedback Used: False
Extra Feedback Remaining (after submission): 0

You have 5 minutes to confirm this submission, afterwards a resubmission is
required.
Continue with this submission? (resources will only be used after confirm)
```

Here is a quick breakdown of the fields in this confirmation message:
- **Grade request for lab**  -- What lab are we grading?
- **Request has locked in timestamp** -- If you hit confirm within the next 5
  minutes, this is the timestamp that will be used for the purposes of grading
  your lab (and determining late-ness).
- **github commit hash to be graded**  -- This is the GitHub hash that will be
  checked out and graded by the autograder.  Ensure it matches the hash you've
  last commited and pushed to your GitHub repository (e.g. with `git log`).
- **Original Due Date**  -- If you were to never use late-days on this lab, when
  would it be due?
- **Previous Due Date** -- Before this submission, what was your due date (any
  late days you've used as a part of prior submissions will be reflected here)?
- **New Due Date** -- After this submission, this is your new due date (after
  late day application).
- **Late Days applied...** -- The number of late-days that will be used as a
  part of this request (remember, you only get 3 for the entire semester).
- **Late Penalty** -- What penalty to your score will you get from this
  submission due to it being late?  
- **Late Days Remaining** -- The number of late days you have remaining for the
  semester (after any late days in this request are used)
- **Feedback Given** -- Will this request give you feedback?
- **Extra Feedback Used** -- Will this request use one of your extra feedbacks?
  (you get 3 per lab)
- **Extra Feedback Remaining** -- How many extra feedbacks will you have after this
  submission?


### Group Creation

The autograder allows creation of groups.  By default every student is in their own
group, with their own repositories.  Starting from lab2, if students wish to partner
with another student, the autograder will support this behavior.  To create a group
and get a github repository for your group please do the following:

1.  Decide on a `group_name`.  This name must be alpha-numeric (only using characters `[a-zA-Z0-9]`).
2.  Have one partner generate an autograder key (NOTE: this key only lasts for 5 minutes)
    - To do so, log into the autograder and click the "Get Group Key" button.
    - The displayed screen will have a unique key
3.  Have the other partner create the group:
    - Select the "Create Group" button
    - Enter your group name in the "Group Name" box
    - Enter your *partner's* key in the Partner Key box
    - Press "Create Group"

Once this process is completed the autograder will begin to make your group.  It will
create a new github repository for you and your partner called `cs3210-f20/<groupname>-xv6-public.git`.
Both you and your partner will have write accesses to this repository, and all future
autograder submissions for either of you will come from this repository.

**NOTES**:  Once you join a group, you cannot leave or form a new group without informing
the instructional staff (we'll help you with that process).  Groups are intended to last
the semester, however we understand that sometimes its best not to stay in your group.  To
discourage group hopping we don't enable creating switching groups (once you've entered your first group)
by default, but we will allow you to switch groups if needed.

[autograder]:https://cs3210-autograder.cc.gatech.edu/index.html
