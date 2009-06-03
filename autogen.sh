M4_BOOTSTRAPS="vala.m4 valadoc.m4 dolt.m4"
M4_BOOTSTRAP_SRC_PATH=${M4_BOOTSTRAP_SRC_PATH:-../autotools}
mkdir -p autotools
for i in $M4_BOOTSTRAPS; do
	if [ -f $M4_BOOTSTRAP_SRC_PATH/$i ]; then
		cp $M4_BOOTSTRAP_SRC_PATH/$i autotools
	else
		echo Warning: file $i is not found, set M4_BOOTSTRAP_SRC_PATH.
	fi
done;
aclocal -I autotools
libtoolize --force --automake
autoheader
automake --add-missing
autoconf
(cd libyaml; autoreconf -fvi;)
if ! test x$1 == x--no-configure; then
./configure --enable-maintainer-mode $*
fi;
