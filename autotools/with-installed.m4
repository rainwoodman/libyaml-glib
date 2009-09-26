dnl define --with-installed-$1 and put the withval to $2=[yes|no]
dnl
dnl weird that AC_ARG_WITH_INSTALLED or ARG_WITH_INSTALLED won't work

AC_DEFUN([WITH_INSTALLED], [
	AC_ARG_WITH(installed-$1,
	[AS_HELP_STRING([--with-installed-$1], [use the exisiting $1]) ],
	[
		if test x$withval = xyes; then
			$2=yes;
		else 
			$2=no;
		fi;
	],
	[ $2=no; ]
	)
	]
)

