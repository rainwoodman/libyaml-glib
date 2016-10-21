
VALAPKGS = --pkg libyaml-glib-1.0 --pkg gee-0.8
VALAFLAGS = --vapidir ../src

noinst_PROGRAMS = libyaml-glib-parser example-invoice

LDADD = -lyaml-glib
LDFLAGS = -L$(top_builddir)/src -export-dynamic
CPPFLAGS = $(LIBYAML_CFLAGS) -I$(top_srcdir)/src $(GLIB_CFLAGS) 
LIBS = $(GLIB_LIBS)

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

