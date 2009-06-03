
VALAPKGS = --pkg libyaml-glib-1.0
VALAFLAGS = --vapidir ../src

noinst_PROGRAMS = libyaml-glib-example
libyaml_glib_example_LDADD = -lyaml-glib
libyaml_glib_example_LDFLAGS = -L$(top_builddir)/src
libyaml_glib_example_CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir)/src $(GLIB_CFLAGS) 

SUFFIXES = .vala .c
.vala.c :
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS)
	touch $@

BUILT_SOURCES = $(noinst_PROGRAMS:=.c)
EXTRA_DIST = $(noinst_PROGRAMS:=.vala)

check-local:
	for i in $(noinst_PROGRAMS); do \
		./$$i; \
    done;

