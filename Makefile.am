if USE_BUILTIN_LIBYAML
SUBDIRS = libyaml
else
SUBDIRS = 
endif

lib_LTLIBRARIES = libyaml-glib.la

libyaml_glib_la_SOURCES = libyaml-glib.c libyaml-glib.h
libyaml_glib_la_CPPFLAGS = $(LIBYAML_CFLAGS) $(GLIB_CFLAGS)
libyaml_glib_la_LIBADD = $(LIBYAML_LIBS) -lyaml $(GLIB_LIBS)
libyaml_glib_la_LDFLAGS = -version-info 0:0:0 -release $(VERSION)

include_HEADERS = libyaml-glib.h
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libyaml-glib-1.0.pc

BUILT_SOURCES = vala-ccode example-ccode

noinst_PROGRAMS = libyaml-glib-example
libyaml_glib_example_SOURCES = libyaml-glib-example.c
libyaml_glib_example_LDADD = libyaml-glib.la
libyaml_glib_example_CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir) $(GLIB_CFLAGS) 
.PHONY: bootstrap

bootstrap: maintainer-clean
	./autogen.sh

$(DIST_SOURCES): vala-ccode example-ccode

vala-ccode: libyaml-glib.vala libyaml-1.0.vapi
	$(VALAC) --library libyaml-glib-1.0 -H libyaml-glib.h -C libyaml-glib.vala libyaml-1.0.vapi
	echo libyaml-1.0 > libyaml-glib-1.0.deps
	touch $@

example-ccode: libyaml-glib-example.vala libyaml-glib-1.0.vapi libyaml-1.0.vapi
	$(VALAC) -C libyaml-glib-example.vala libyaml-1.0.vapi libyaml-glib-1.0.vapi
	touch $@

EXTRA_DIST = libyaml-1.0.vapi \
             libyaml-glib.vala \
             libyaml-glib-example.vala \
             libyaml-glib-1.0.vapi \
             libyaml-glib-1.0.deps \
             vala-ccode \
             example-ccode \
             autogen.sh

DISTCLEANFILES = libyaml-glib-1.0.vapi \
                 libyaml-glib-1.0.gir \
                 libyaml-glib-1.0.deps \
                 doltcompile doltlibtool  \
                 libyaml-glib-1.0.pc

MAINTAINERCLEANFILES = libyaml-glib.c libyaml-glib.h libyaml-glib-example.c
