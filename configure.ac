
AC_PREREQ(2.59)
AC_INIT([yaml-glib], [0.1], [rainwoodman@gmail.com])
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

PKG_PROG_PKG_CONFIG([0.21])

PKG_CHECK_MODULES(GLIB, [glib-2.0 >= 2.10 gobject-2.0 >= 2.10 gmodule-2.0 >= 2.10])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

AC_ARG_WITH(with_builtin_libyaml,
	[ AS_HELP_STRING([--with-builtin-libyaml], [use the builtin libyaml]) ],
	[],
	[with_builtin_libyaml=check]
)

if test "x$with_builtin_libyaml" != xyes; then
	PKG_CHECK_MODULES(LIBYAML, [libyaml-1.0 >= 0.1.2],
	[ 
		AC_MSG_WARN([linking against libyaml installed in the system]) 
		with_builtin_libyaml=no;
	], [
		if test "x$with_builtin_libyaml" != xcheck; then
			AC_MSG_FAILURE([libyaml not found in the system.])
		fi
	])
fi
if test "x$with_builtin_libyaml" != xno; then
	AC_MSG_WARN([building libyaml as a subpackage]);
	AC_CONFIG_SUBDIRS([libyaml])
	LIBYAML_CFLAGS='-I$(top_srcdir)/libyaml/include';
	LIBYAML_LIBS='-L$(top_builddir)/libyaml/src -lyaml';
	use_builtin_libyaml=yes;
fi
AC_SUBST(LIBYAML_CFLAGS)
AC_SUBST(LIBYAML_LIBS)
AM_CONDITIONAL(USE_BUILTIN_LIBYAML, [test x$use_builtin_libyaml == xyes])
AC_CONFIG_FILES([
libyaml-glib-1.0.pc
Makefile
src/Makefile
tests/Makefile
])
AC_OUTPUT
