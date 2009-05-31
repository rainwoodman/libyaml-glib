if USE_BUILTIN_LIBYAML
SUBDIRS = libyaml
else
SUBDIRS = 
endif

lib_LTLIBRARIES = libyaml-glib.la

VALASOURCES = libyaml-glib.vala error.vala buildable.vala builder.vala
libyaml_glib_la_SOURCES = $(VALASOURCES:.vala=.c) libyaml-glib.h
libyaml_glib_la_CPPFLAGS = $(LIBYAML_CFLAGS) $(GLIB_CFLAGS)
libyaml_glib_la_LIBADD = $(LIBYAML_LIBS) -lyaml $(GLIB_LIBS)
libyaml_glib_la_LDFLAGS = -version-info 0:0:0 -release $(VERSION)

include_HEADERS = libyaml-glib.h
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libyaml-glib-1.0.pc

BUILT_SOURCES = vala-ccode example-ccode vala-doc

noinst_PROGRAMS = libyaml-glib-example
libyaml_glib_example_SOURCES = libyaml-glib-example.c
libyaml_glib_example_LDADD = libyaml-glib.la
libyaml_glib_example_CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir) $(GLIB_CFLAGS) 
.PHONY: bootstrap

bootstrap: maintainer-clean
	./autogen.sh

$(DIST_SOURCES): vala-ccode example-ccode

vala-ccode: $(VALASOURCES) libyaml-1.0.vapi
	$(VALAC) --library libyaml-glib-1.0 -H libyaml-glib.h -C $(VALASOURCES) libyaml-1.0.vapi --pkg gmodule-2.0
	echo libyaml-1.0 > libyaml-glib-1.0.deps
	touch $@

if ENABLE_VALADOC
vala-doc: $(VALASOURCES) libyaml-1.0.vapi
	$(VALADOC) -o Documentation --package-name libyaml-glib-1.0 $(VALASOURCES) libyaml-1.0.vapi --pkg gmodule-2.0
	touch $@
else
vala-doc:
	touch $@
endif
example-ccode: libyaml-glib-example.vala libyaml-glib-1.0.vapi libyaml-1.0.vapi
	$(VALAC) -C libyaml-glib-example.vala libyaml-1.0.vapi libyaml-glib-1.0.vapi
	touch $@

EXTRA_DIST = libyaml-1.0.vapi \
             $(VALA_SOURCES) \
             libyaml-glib-example.vala \
             libyaml-glib-1.0.vapi \
             libyaml-glib-1.0.deps \
             vala-ccode \
             example-ccode \
             autogen.sh \
             Documentation

DISTCLEANFILES =  \
                 libyaml-glib-1.0.gir \
                 doltcompile doltlibtool  \
                 libyaml-glib-1.0.pc

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) libyaml-glib.h \
                       libyaml-glib-example.c \
                       libyaml-glib-1.0.vapi \
                       libyaml-glib-1.0.deps
