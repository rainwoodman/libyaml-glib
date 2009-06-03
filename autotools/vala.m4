dnl Autoconf scripts for the Vala compiler
dnl Copyright (C) 2007  Mathias Hasselmann
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2 of the License, or (at your option) any later version.

dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.

dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
dnl
dnl Author:
dnl 	Mathias Hasselmann <mathias.hasselmann@gmx.de>
dnl 	Yu Feng <rainwoodman@gmail.com>
dnl --------------------------------------------------------------------------

dnl VALA_PROG_VALAC([MINIMUM-VERSION])
dnl
dnl Check whether the Vala compiler exists in `PATH'. If it is found the
dnl variable VALAC is set. Optionally a minimum release number of the compiler
dnl can be requested.

dnl Rules are provided to ease building one target per Makefile
dnl @VALA_CCODE_RULES@ compiles VALASOURCES into corresponding CCode
dnl @VALA_OBJECT_RULES@ compiles VALASOURCES into corresponding objects
dnl
dnl $(top_srcdir)/vapi is used to override default vapi files in case needed.
dnl VALASOURCES = source files to compile
dnl VALAFLAGS = valac parameters
dnl VALAPKGS = packages (vapi files) 

dnl EXAMPLE:
dnl # for vala 0.6.x branch,
dnl # 0.7.x differs from this because .h files are not produded.
dnl
dnl VALASOURCES = foo.vala bar.vala
dnl VALAPKGS = gtk+-2.0 my-pkg
dnl VALAFLAGS = --library=foobar --vapidir=my-vapidir
dnl foobar_SOURCES = $(VALASOURCES:.vala=.c) $(VALASOURCE:.vala=.h)
dnl foobar_CPPFLAGS = $(GLIB_CFLAGS) $(GTK_CFLAGS) -include config.h
dnl foobar_LDADD = $(GTK_LIBS)
dnl BUILT_SOURCES = vala-ccode
dnl @VALA_CCODE_RULE@
dnl EXTRA_DIST = $(VALASOURCES)
dnl 
dnl --------------------------------------------------------------------------
AC_DEFUN([VALA_PROG_VALAC],[
  AC_PATH_PROG([VALAC_BIN], [valac], [])
  AC_SUBST(VALAC_BIN)
  VALAC="$VALAC_BIN \$(vala_default_vapi_dirs)"
  AC_SUBST(VALAC)
  VALA_CCODE_RULES='vala-ccode: $(VALASOURCES); $(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS) && touch vala-ccode'
  AC_SUBST(VALA_CCODE_RULES)

  if test -z "x${VALAC_BIN}"; then
    AC_MSG_WARN([No Vala compiler found. You will not be able to recompile .vala source files.])
  elif test -n "x$1"; then
    AC_REQUIRE([AC_PROG_AWK])
    AC_MSG_CHECKING([valac is at least version $1])

    if "${VALAC_BIN}" --version | "${AWK}" -v r='$1' 'function vn(s) { if (3 == split(s,v,".")) return (v[1]*1000+v[2])*1000+v[3]; else exit 2; } /^Vala / { exit vn(r) > vn($[2]) }'; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([Vala $1 not found.])
    fi
  fi
])

AC_DEFUN([VALA_VAPI_DIRS], [
	if test "x$2" == x; then
		vala_default_vapi_dirs=
		for i in $1; do 
			vala_default_vapi_dirs="$vala_default_vapi_dirs --vapidir=$i";
		done;
		AC_SUBST(vala_default_vapi_dirs)
	else
		vala_tmp=
		for i in $2; do 
			vala_tmp="$vala_tmp --vapidir=$i";
		done;
		$1="$vala_tmp"
	fi
])
