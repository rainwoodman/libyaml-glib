SUBDIRS = src tests
if USE_BUILTIN_LIBYAML
SUBDIRS += libyaml
endif

.PHONY: bootstrap
bootstrap: maintainer-clean
	./autogen.sh

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libyaml-glib-1.0.pc

DISTCLEANFILES =  \
                 doltcompile doltlibtool  \
                 libyaml-glib-1.0.pc
