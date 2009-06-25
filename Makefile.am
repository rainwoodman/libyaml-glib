if USE_BUILTIN_LIBYAML
SUBDIRS = libyaml src tests
else
SUBDIRS = src tests
endif

.PHONY: bootstrap
bootstrap: maintainer-clean
	./autogen.sh

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libyaml-glib-1.0.pc

DISTCLEANFILES =  \
                 doltcompile doltlibtool  \
                 libyaml-glib-1.0.pc
doc_DATA = README

EXTRA_DIST = \
	autogen.sh \
	libyaml-glib-1.0.spec \
	README
