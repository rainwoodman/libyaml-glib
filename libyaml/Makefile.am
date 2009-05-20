## Run `./bootstrap` to generate the "Makefile.in" files in this directory and
## the "$SUBDIRS" subdirectories.

SUBDIRS = include src . tests win32

EXTRA_DIST = README LICENSE doc/doxygen.cfg

maintainer-clean-local:
	-rm -f aclocal.m4 config.h.in configure config/*
	-find ${builddir} -name Makefile.in -exec rm -f '{}' ';'

pkgconfigdir=$(libdir)/pkgconfig
pkgconfig_DATA= libyaml-1.0.pc

.PHONY: bootstrap
bootstrap: maintainer-clean
	./bootstrap

DISTCLEANFILES = libyaml-1.0.pc
