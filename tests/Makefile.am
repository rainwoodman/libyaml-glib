
VALAPKGS = --pkg libyaml-glib-1.0
VALAFLAGS = --vapidir ../src

noinst_PROGRAMS = libyaml-glib-parser libyaml-glib-builder
libyaml_glib_parser_LDADD = -lyaml-glib
libyaml_glib_parser_LDFLAGS = -L$(top_builddir)/src
libyaml_glib_parser_CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir)/src $(GLIB_CFLAGS) 
libyaml_glib_builder_LDADD = -lyaml-glib
libyaml_glib_builder_LDFLAGS = -L$(top_builddir)/src -export-dynamic
libyaml_glib_builder_CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir)/src $(GLIB_CFLAGS) 

SUFFIXES = .vala .c
.vala.c :
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS)
	touch $@

BUILT_SOURCES = $(noinst_PROGRAMS:=.c)
EXTRA_DIST = $(noinst_PROGRAMS:=.vala)

#check-local:
#	for i in $(noinst_PROGRAMS); do \
#		./$$i; \
#    done;

