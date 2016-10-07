
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

PKG_CHECK_MODULES(GLIB, [glib-2.0 >= 2.10 gobject-2.0 >= 2.10 gmodule-2.0 >= 2.10])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES(LIBYAML, yaml-0.1 >= 0.1.2 )

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
