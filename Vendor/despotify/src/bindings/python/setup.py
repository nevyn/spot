#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
from distutils.core import setup, Extension
import commands

def pkgconfig(*packages, **kw):
    flag_map = {'-I': 'include_dirs', '-L': 'library_dirs', '-l': 'libraries'}

    for token in commands.getoutput("pkg-config --libs --cflags %s" % ' '.join(packages)).split():
        if flag_map.has_key(token[:2]):
            kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
        else: # throw others to extra_link_args
            kw.setdefault('extra_link_args', []).append(token)

    for k, v in kw.iteritems(): # remove duplicated
        kw[k] = list(set(v))

    return kw

files = map(lambda f: 'src/' + f, ['callback.c', 'spytify.c'])

setup(name         = 'spytify',
      version      = 'v0.1',
      description  = 'spytify - Python bindings for libdespotify',
      author       = 'Jørgen Pedersen Tjernø',
      author_email = 'jorgen@devsoft.no',
      license      = 'New BSD (3-clause BSD)',
      ext_modules  = [Extension('spytify', files, **pkgconfig('despotify'))]
     )

