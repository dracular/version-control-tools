#require bmodocker
  $ . $TESTDIR/hgext/bzexport/tests/helpers.sh

  $ $TESTDIR/d0cker start-bmo bzexport-test-review $HGPORT
  waiting for Bugzilla to start
  Bugzilla accessible on http://$DOCKER_HOSTNAME:$HGPORT/

  $ configurebzexport $HGPORT $HGRCPATH

Create some Bugzilla users

  $ adminbugzilla create-user user1@example.com password1 'Mary Jane [:mary]'
  created user 6
  $ adminbugzilla create-user user2@example.com password2 'Bob Jones [:bob]'
  created user 7

Set up repo and Bugzilla state

  $ hg init repo
  $ cd repo
  $ touch foo
  $ hg -q commit -A -m 'initial'

  $ bugzilla create-bug TestProduct TestComponent bug1

Specifying a reviewer by IRC nick works

  $ echo first > foo
  $ hg qnew -d '0 0' -m 'Bug 1 - Testing reviewer' test-reviewer

  $ out=`bugzilla create-login-cookie`
  $ userid=`echo ${out} | awk '{print $1}'`
  $ cookie=`echo ${out} | awk '{print $2}'`

  $ hg --config bugzilla.userid=${userid} --config bugzilla.cookie=${cookie} bzexport --review ':mary'
  Refreshing configuration cache for http://$DOCKER_HOSTNAME:$HGPORT/bzapi/
  Requesting review from user1@example.com
  test-reviewer uploaded as http://$DOCKER_HOSTNAME:$HGPORT/attachment.cgi?id=1&action=edit

  $ bugzilla dump-bug 1
  Bug 1:
    attachments:
    - attacher: default@example.com
      content_type: text/plain
      data: "# HG changeset patch\n# User test\n# Date 0 0\n#      Thu Jan 01 00:00:00\
        \ 1970 +0000\n# Node ID 141273a2a25953ea9b916eb5d232728c6ef01383\n# Parent \
        \ 96ee1d7354c4ad7372047672c36a1f561e3a6a4c\nBug 1 - Testing reviewer\n\ndiff\
        \ -r 96ee1d7354c4 -r 141273a2a259 foo\n--- a/foo\tThu Jan 01 00:00:00 1970 +0000\n\
        +++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -0,0 +1,1 @@\n+first\n"
      description: Testing reviewer
      file_name: bug-1-test-reviewer
      flags:
      - id: 1
        name: review
        requestee: user1@example.com
        setter: default@example.com
        status: '?'
      id: 1
      is_obsolete: false
      is_patch: true
      summary: Testing reviewer
    blocks: []
    cc:
    - user1@example.com
    comments:
    - author: default@example.com
      id: 1
      tags: []
      text: ''
    - author: default@example.com
      id: 2
      tags: []
      text:
      - Created attachment 1
      - Testing reviewer
    component: TestComponent
    depends_on: []
    platform: All
    product: TestProduct
    resolution: ''
    status: ASSIGNED
    summary: bug1

Parsing reviewer out of commit message works

  $ bugzilla create-bug TestProduct TestComponent bug2
  $ echo second >> foo
  $ hg qnew -d '0 0' second -m 'Bug 2 - Auto reviewer; r=bob'
  $ hg bzexport --review auto
  Requesting review from user2@example.com
  second uploaded as http://$DOCKER_HOSTNAME:$HGPORT/attachment.cgi?id=2&action=edit

  $ bugzilla dump-bug 2
  Bug 2:
    attachments:
    - attacher: default@example.com
      content_type: text/plain
      data: "# HG changeset patch\n# User test\n# Date 0 0\n#      Thu Jan 01 00:00:00\
        \ 1970 +0000\n# Node ID c5327b68c8ab03f183556597ca1df25d020a1010\n# Parent \
        \ 141273a2a25953ea9b916eb5d232728c6ef01383\nBug 2 - Auto reviewer; r=bob\n\n\
        diff -r 141273a2a259 -r c5327b68c8ab foo\n--- a/foo\tThu Jan 01 00:00:00 1970\
        \ +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,1 +1,2 @@\n first\n\
        +second\n"
      description: Auto reviewer
      file_name: bug-2-second
      flags:
      - id: 2
        name: review
        requestee: user2@example.com
        setter: default@example.com
        status: '?'
      id: 2
      is_obsolete: false
      is_patch: true
      summary: Auto reviewer
    blocks: []
    cc:
    - user2@example.com
    comments:
    - author: default@example.com
      id: 3
      tags: []
      text: ''
    - author: default@example.com
      id: 4
      tags: []
      text:
      - Created attachment 2
      - Auto reviewer
    component: TestComponent
    depends_on: []
    platform: All
    product: TestProduct
    resolution: ''
    status: ASSIGNED
    summary: bug2

Changing the reviewer works

  $ bugzilla create-bug TestProduct TestComponent bug3
  $ echo third >> foo
  $ hg qnew -d '0 0' third -m 'Bug 3 - Switching reviewer'
  $ hg bzexport --review :mary
  Requesting review from user1@example.com
  third uploaded as http://$DOCKER_HOSTNAME:$HGPORT/attachment.cgi?id=3&action=edit

  $ hg bzexport --review :bob
  Requesting review from user2@example.com
  bug-3-third uploaded as http://$DOCKER_HOSTNAME:$HGPORT/attachment.cgi?id=4&action=edit

  $ bugzilla dump-bug 3
  Bug 3:
    attachments:
    - attacher: default@example.com
      content_type: text/plain
      data: "# HG changeset patch\n# User test\n# Date 0 0\n#      Thu Jan 01 00:00:00\
        \ 1970 +0000\n# Node ID a6be8c5631850a9dbd33aade9eaa136ac302c0b3\n# Parent \
        \ c5327b68c8ab03f183556597ca1df25d020a1010\nBug 3 - Switching reviewer\n\ndiff\
        \ -r c5327b68c8ab -r a6be8c563185 foo\n--- a/foo\tThu Jan 01 00:00:00 1970 +0000\n\
        +++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,2 +1,3 @@\n first\n second\n\
        +third\n"
      description: Switching reviewer
      file_name: bug-3-third
      flags: []
      id: 3
      is_obsolete: true
      is_patch: true
      summary: Switching reviewer
    - attacher: default@example.com
      content_type: text/plain
      data: "# HG changeset patch\n# User test\n# Date 0 0\n#      Thu Jan 01 00:00:00\
        \ 1970 +0000\n# Node ID a6be8c5631850a9dbd33aade9eaa136ac302c0b3\n# Parent \
        \ c5327b68c8ab03f183556597ca1df25d020a1010\nBug 3 - Switching reviewer\n\ndiff\
        \ -r c5327b68c8ab -r a6be8c563185 foo\n--- a/foo\tThu Jan 01 00:00:00 1970 +0000\n\
        +++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,2 +1,3 @@\n first\n second\n\
        +third\n"
      description: Switching reviewer
      file_name: bug-3-third
      flags:
      - id: 4
        name: review
        requestee: user2@example.com
        setter: default@example.com
        status: '?'
      id: 4
      is_obsolete: false
      is_patch: true
      summary: Switching reviewer
    blocks: []
    cc:
    - user1@example.com
    - user2@example.com
    comments:
    - author: default@example.com
      id: 5
      tags: []
      text: ''
    - author: default@example.com
      id: 6
      tags: []
      text:
      - Created attachment 3
      - Switching reviewer
    - author: default@example.com
      id: 7
      tags: []
      text:
      - Created attachment 4
      - Switching reviewer
    component: TestComponent
    depends_on: []
    platform: All
    product: TestProduct
    resolution: ''
    status: ASSIGNED
    summary: bug3

Specifying both reviewer and feedback works

  $ bugzilla create-bug TestProduct TestComponent bug4
  $ echo 4th >> foo
  $ hg qnew -d '0 0' -m 'Bug 4 - Review and feedback' fourth
  $ hg bzexport --review :mary --feedback :bob
  Requesting review from user1@example.com
  Requesting feedback from user2@example.com
  fourth uploaded as http://$DOCKER_HOSTNAME:$HGPORT/attachment.cgi?id=5&action=edit

  $ bugzilla dump-bug 4
  Bug 4:
    attachments:
    - attacher: default@example.com
      content_type: text/plain
      data: "# HG changeset patch\n# User test\n# Date 0 0\n#      Thu Jan 01 00:00:00\
        \ 1970 +0000\n# Node ID abdd660499bc283de2d0e677c1f0b0ff601d534d\n# Parent \
        \ a6be8c5631850a9dbd33aade9eaa136ac302c0b3\nBug 4 - Review and feedback\n\n\
        diff -r a6be8c563185 -r abdd660499bc foo\n--- a/foo\tThu Jan 01 00:00:00 1970\
        \ +0000\n+++ b/foo\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,3 +1,4 @@\n first\n\
        \ second\n third\n+4th\n"
      description: Review and feedback
      file_name: bug-4-fourth
      flags:
      - id: 5
        name: feedback
        requestee: user2@example.com
        setter: default@example.com
        status: '?'
      - id: 6
        name: review
        requestee: user1@example.com
        setter: default@example.com
        status: '?'
      id: 5
      is_obsolete: false
      is_patch: true
      summary: Review and feedback
    blocks: []
    cc:
    - user1@example.com
    - user2@example.com
    comments:
    - author: default@example.com
      id: 8
      tags: []
      text: ''
    - author: default@example.com
      id: 9
      tags: []
      text:
      - Created attachment 5
      - Review and feedback
    component: TestComponent
    depends_on: []
    platform: All
    product: TestProduct
    resolution: ''
    status: ASSIGNED
    summary: bug4

  $ $TESTDIR/d0cker stop-bmo bzexport-test-review
  stopped 1 containers

