#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
# Simple test to show how Spytify works.
# Copyright Jørgen P. Tjernø <jorgen@devsoft.no>

from code import InteractiveConsole
from getpass import getpass
import sys

from spytify import *

def main():
    print "Enter your username: ",
    username = sys.stdin.readline().strip()

    if not username:
        print >>sys.stderr, "Empty username, exiting."
        sys.exit(1)

    password = getpass("Enter your password: ").strip()
    if not password:
        print >>sys.stderr, "Empty password, exiting."
        sys.exit(1)

    print

    s = Spytify(username, password)

    methods = sorted(filter(lambda m: not m.startswith('__'), dir(s)))

    banner = '''Python %s

    Everything from the spytify module has been imported.
    The variable "s" is your current Spotify™ connection, and has the following methods:
        %s
    ''' % (sys.version, ', '.join(methods))

    InteractiveConsole(locals=locals()).interact(banner)

if __name__ == '__main__':
    main()
