if USE_INSTALLED_LIBYAML
SUBDIRS = src tests
else
SUBDIRS = libyaml src tests
endif

.PHONY: bootstrap gen-ChangeLog
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
	gitlog-to-changelog \
	README

dist-hook: gen-ChangeLog
gen_start_date = 2009-03-01

gen-ChangeLog:
	if test -d .git; then						\
	  $(top_srcdir)/gitlog-to-changelog				\
	    --since=$(gen_start_date) > $(distdir)/cl-t;		\
	  rm -f $(distdir)/ChangeLog;					\
	  mv $(distdir)/cl-t $(distdir)/ChangeLog;			\
	fi
