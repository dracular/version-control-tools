  INFO:mozreviewbot:reviewing revision: 1978e5417012 (review request: 2)
  description:
  - Bug 1 - Bad Python
  - ''
  - 'MozReview-Commit-ID: 124Bxg'
  commit_extra_data:
    p2rb.commit_id: 1978e5417012a5f63128d09cfd52c52077c761cb
  diffs:
  - id: 2
    revision: 1
    base_commit_id: 7c5bdf0cec4a90edb36300f8f3679857f46db829
    name: diff
    extra: {}
    patch:
    - diff --git a/foo.py b/foo.py
    - new file mode 100644
    - '--- /dev/null'
    - +++ b/foo.py
    - '@@ -0,0 +1,5 @@'
    - '+def a(): pass'
    - +
    - '+  '
    - '+def b():'
    - +    foo = True
    - ''
  INFO:mozreviewbot:reviewing revision: c768227fc261 (review request: 4)
  description:
  - Bug 2 - pyflakes
  - ''
  - 'MozReview-Commit-ID: 5ijR9k'
  commit_extra_data:
    p2rb.commit_id: c768227fc261de5a93e0c813e0ba4a54e24d2697
  diffs:
  - id: 4
    revision: 1
    base_commit_id: 7c5bdf0cec4a90edb36300f8f3679857f46db829
    name: diff
    extra: {}
    patch:
    - diff --git a/f401.py b/f401.py
    - new file mode 100644
    - '--- /dev/null'
    - +++ b/f401.py
    - '@@ -0,0 +1,1 @@'
    - +import sys
    - ''
  stopped 9 containers