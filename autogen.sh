#!/bin/sh

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

ORIGDIR=`pwd`
cd $srcdir

M4_BOOTSTRAPS="vala.m4 valadoc.m4 dolt.m4 with-installed.m4"
M4_BOOTSTRAP_SRC_PATH=${M4_BOOTSTRAP_SRC_PATH:-../autotools}
mkdir -p autotools
for i in $M4_BOOTSTRAPS; do
	if [ -f $M4_BOOTSTRAP_SRC_PATH/$i ]; then
		cp $M4_BOOTSTRAP_SRC_PATH/$i autotools
	else
		echo Warning: file $i is not found, not updating m4 macros.
		echo set M4_BOOTSTRAP_SRC_PATH to the macro repository
	fi
done;

touch ChangeLog || exit $?

aclocal -I autotools || exit $?
libtoolize --force --automake || exit $?
autoheader || exit $?
automake --add-missing || exit $?
autoconf || exit $?
(cd libyaml; autoreconf -vi;) || exit $?

cd $ORIGDIR || exit $?

if ! test x$1 == x--no-configure; then
./configure --enable-maintainer-mode $*
fi;

