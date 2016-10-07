lib_LTLIBRARIES = libyaml-glib.la

VALASOURCES = libyaml-glib.vala error.vala buildable.vala builder.vala loader.vala writer.vala
libyaml_glib_la_SOURCES = $(VALASOURCES:.vala=.c) libyaml-glib-1.0.h
libyaml_glib_la_CPPFLAGS = $(LIBYAML_CFLAGS) $(GLIB_CFLAGS)
libyaml_glib_la_LIBADD = $(LIBYAML_LIBS) $(GLIB_LIBS)
libyaml_glib_la_LDFLAGS = -version-info 0:0:0 -release $(VERSION)

BUILT_SOURCES = vala-ccode vala-doc


$(DIST_SOURCES): vala-ccode

vala-ccode: $(VALASOURCES) yaml-0.1.vapi
	$(VALAC) -g --library libyaml-glib-1.0 -H libyaml-glib-1.0.h -C $(VALASOURCES) yaml-0.1.vapi --pkg gmodule-2.0
	echo yaml-0.1 > libyaml-glib-1.0.deps
	touch $@

if ENABLE_VALADOC
vala-doc: $(VALASOURCES) yaml-0.1.vapi
	$(VALADOC) -o Documentation --package-name libyaml-glib-1.0 $(VALASOURCES) yaml-0.1.vapi --pkg gmodule-2.0
	touch $@
else
vala-doc:
	mkdir -p Documentation
	touch $@
endif

vapi_DATA = libyaml-glib-1.0.vapi libyaml-glib-1.0.deps yaml-0.1.vapi yaml-0.1.vapi
vapidir=$(datadir)/vala/vapi
pkginclude_HEADERS = libyaml-glib-1.0.h

EXTRA_DIST = yaml-0.1.vapi \
             $(VALASOURCES) \
             libyaml-glib-1.0.vapi \
             libyaml-glib-1.0.deps \
             vala-ccode \
             vala-doc \
             Documentation

DISTCLEANFILES =

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) libyaml-glib-1.0.h \
                       libyaml-glib-1.0.vapi \
                       libyaml-glib-1.0.deps \
                       Documentation
