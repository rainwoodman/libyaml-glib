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
dnl      :wYu Feng
dnl --------------------------------------------------------------------------

dnl VALA_PROG_VALADOC
dnl
dnl Check whether the Valadoc compiler exists in `PATH'. If it is found the
dnl variable VALADOC is set.
dnl 
dnl --enable-valadoc is added to the configure script.
dnl The default value is yes. 
dnl However if valadoc is not found it is reverted to no.

dnl An automake rule @VALA_DOC_RULES@ is provided to simplify 
dnl invoking valadoc. $(topsrc_dir)/vapidir is used to override
dnl the default vapi directory. --force is added to valadoc parameters
dnl to avoid possible problems.
dnl
dnl EXAMPLE:(Used together with vala.m4)
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
dnl if ENABLE_VALADOC
dnl VALADOCFLAGS = --package-name=foobar -o Documentation --vapidir=my-vapidir
dnl @VALA_DOC_RULES@
dnl BUILT_SOUCES+=vala-doc
dnl #foobardoc_FILES=Documentation
dnl #foobardocdir=$(package_datadir)/Documentation
dnl endif
dnl --------------------------------------------------------------------------

AC_DEFUN([VALA_PROG_VALADOC],[
  enable_valadoc=yes
  AC_ARG_ENABLE(
    [valadoc],
    AC_HELP_STRING([--enable-valadoc], [default is yes]),
    [ test "x$enableval" == xno && enable_valadoc=yes ],
    [ enable_valadoc=yes ])

  AS_IF([test "x$enable_valadoc" == xyes ],
    [ AC_PATH_PROG([VALADOC_BIN], [valadoc], [])
      AS_IF([ test -z "${VALADOC_BIN}" ],
        AC_MSG_WARN([No valadoc found. You will not be able to generate document files.]) 
        enable_valadoc=no
      )
    ])

  AM_CONDITIONAL(ENABLE_VALADOC, [ test "x$enable_valadoc" == xyes ])

  AC_SUBST(VALADOC_BIN)
  VALADOC="$VALADOC_BIN --force \$(vala_default_vapi_dirs)"
  AC_SUBST(VALADOC)
  VALA_DOC_RULES='vala-doc: $(VALASOURCES); $(VALADOC) $(VALADOCFLAGS) $^ $(VALAPKGS) && touch vala-doc'

  AC_SUBST(VALA_DOC_RULES)

])
