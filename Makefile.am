lib_LTLIBRARIES = libyaml-glib.la

libyaml_glib_la_SOURCES = libyaml-glib.c libyaml-glib.h
libyaml_glib_la_CPPFLAGS = -I../libyaml/include $(GLIB_CFLAGS)
libyaml_glib_la_LIBADD = ../libyaml/src/libyaml.la $(GLIB_LIBS)

include_HEADERS = libyaml-glib.h
BUILT_SOURCES = vala-ccode test-ccode

noinst_PROGRAMS = libyaml-glib-test
libyaml_glib_test_SOURCES = libyaml-glib-test.c
libyaml_glib_test_LDADD = libyaml-glib.la
libyaml_glib_test_CPPFLAGS = -I../libyaml/include -I. $(GLIB_CFLAGS) 

vala-ccode: libyaml-glib.vala libyaml-1.0.vapi
	$(VALAC) --library libyaml-glib-1.0 -H libyaml-glib.h -C libyaml-glib.vala libyaml-1.0.vapi
	touch $@

test-ccode: libyaml-glib-test.vala libyaml-glib-1.0.vapi libyaml-1.0.vapi
	$(VALAC) -C libyaml-glib-test.vala libyaml-1.0.vapi libyaml-glib-1.0.vapi
	touch $@

EXTRA_DIST = libyaml-1.0.vapi libyaml-glib.vala libyaml-glib-test.vala libyaml-glib-1.0.vapi

DISTCLEANFILES = libyaml-glib-1.0.vapi
