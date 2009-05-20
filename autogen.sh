mkdir -p config
aclocal -I config
libtoolize --force --automake
autoheader
automake --add-missing
autoconf
(cd libyaml; autoreconf -fvi;)
if ! test x$1 == x--no-configure; then
./configure --enable-maintainer-mode $*
fi;
