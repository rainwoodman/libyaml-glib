
AC_PREREQ(2.59)
AC_INIT([yaml-glib], [0.1.1], [rainwoodman@gmail.com])
AC_CONFIG_MACRO_DIR([autotools])
AC_CONFIG_AUX_DIR([autotools])
AC_SUBST(ACLOCAL_AMFLAGS, "-I autotools")
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([1.9 foreign])

AM_MAINTAINER_MODE
AC_PROG_LIBTOOL
DOLT

AC_PROG_CC
AM_PROG_CC_C_O
VALA_PROG_VALAC([0.7.2])
VALA_PROG_VALADOC

#docdir fix for autoconf 2.59
docdir='${datadir}/doc/${PACKAGE_TARNAME}'
AC_SUBST(docdir)

PKG_PROG_PKG_CONFIG([0.21])

PKG_CHECK_MODULES(GLIB, [glib-2.0 >= 2.32 gobject-2.0 >= 2.32 gmodule-2.0 >= 2.32])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)


WITH_INSTALLED([libyaml], [use_installed_libyaml])

if test x$use_installed_libyaml = xno; then
	AC_CONFIG_SUBDIRS([libyaml])
	LIBYAML_CFLAGS='-I$(top_srcdir)/libyaml/include';
	LIBYAML_LIBS='$(top_builddir)/libyaml/src/libyaml.la';
else
	PKG_CHECK_MODULES(LIBYAML, libyaml >= 0.1.4 )
fi;

AC_SUBST(LIBYAML_CFLAGS)
AC_SUBST(LIBYAML_LIBS)
AM_CONDITIONAL(USE_INSTALLED_LIBYAML, [test x$use_builtin_libyaml == xno])

AC_CONFIG_FILES([
libyaml-glib-1.0.pc
Makefile
src/Makefile
tests/Makefile
])
AC_OUTPUT
