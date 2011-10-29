#!/usr/bin/python
# Copyright (C) 2011 Mozilla Foundation
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

import re
import time
import datetime
from mercurial.node import hex

# Before enabling this hook on mozilla-central (and feeder repos), this should be
# set to a date in the near future.
DATE_HOOK_ENABLED = time.mktime(datetime.datetime(2011, 10, 01).timetuple()) # October 2011 (CHANGE ME)

goodMessage = [re.compile(x, re.I) for x in [
    r'bug\s+\#?[0-9]+',
    r'b=[0-9]+',
    r'no bug',

    r'^(back(ing|ed)?\s+out|backout).*(\s+|\:)[0-9a-f]{12}',
    r'^(revert(ed|ing)?).*(\s+|\:)[0-9a-f]{12}',
    r'^update nanojit-import-rev stamp\.',
    r'^add(ed|ing)? tag'
]]

def isGoodMessage(c):
    def message(fmt):
        #print fmt.format(rev = hex(c.node())[:12]) Disabled for python 2.4
        print fmt.replace('{rev}', hex(c.node())[:12])
        print c.user()
        print c.description()
        print ""

    desc = c.description()
    if c.user() in ["ffxbld", "seabld", "tbirdbld", "cltbld"]:
        return True
    
    if "try: " in desc:
        message("Rev {rev} uses try syntax. (Did you mean to push to Try instead?)")
        return False

    for r in goodMessage:
        if r.search(desc):
            return True
    
    dlower = desc.lower()
    if dlower.startswith("merge") or dlower.startswith("merging") or dlower.startswith("automated merge"):
        if len(c.parents()) == 2:
            return True
        else:
            message("Rev {rev} claims to be a merge, but it has only one parent.")
            return False

    if dlower.startswith("back") or dlower.startswith("revert"):
        # Purposely ambiguous: it's ok to say "backed out rev N" or "reverted to rev N-1"
        message("Backout rev {rev} needs a bug number or a rev id.")
    else:
        message("Rev {rev} needs a bug number.")

    return False

def hook(ui, repo, node, hooktype, **kwargs):
    # All changesets from node to "tip" inclusive are part of this push.
    rev = repo.changectx(node).rev()
    tip = repo.changectx("tip").rev()
    rejecting = False

    for i in reversed(xrange(rev, tip + 1)):
        c = repo.changectx(i)

        if c.date()[0] < DATE_HOOK_ENABLED:
            continue
        
        if "IGNORE BAD COMMIT MESSAGES" in c.description(): 
            # Ignore commit messages for all earlier revs in this push.
            break
        
        if not isGoodMessage(c):
            # Keep looping so the pusher sees all commits they need to fix.
            rejecting = True
    
    if not rejecting:
      return 0

    # We want to allow using this hook locally
    if hooktype == "pretxnchangegroup":
        return 1

    print "This changeset would have been rejected!"
    return 0 # to fail not warn change to 1
