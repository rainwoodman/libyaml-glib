yaml-glib - Building GObject from YAML

Travis Status

.. image:: https://travis-ci.org/rainwoodman/libyaml-glib.svg?branch=master
    :target: https://travis-ci.org/rainwoodman/libyaml-glib

Introduction
============

yaml-glib is the GLib binding of libyaml, plus a GObject builder
that understands YAML.

Source
======

The source code is hosted at github:

.. code::

  $ git clone git://github.com/fengy-research/libyaml-glib.git

No released tarball is available currently.


Dependencies
============

-  glib2 >= 2.10            GLib and GObject 
-  valac >= 0.7.2           Vala compiler

-  libyaml == 0.1.2         YAML 1.1 parser
     built into the source tree, considering its current availability.

Install
=======

The header files and libraries of libyaml are also installed.

1. Direct install (on most distributions)

.. code::

  $ ./autogen.sh --prefix=/usr
  $ make
  $ make install

  2. Build RPM and install from the rpm

.. code::

  $ ./autogen.sh
  $ make
  $ make dist

The next step either requires your rpmdevtree is properly setup

.. code::

  $ rpmbuild -ta yaml-glib-0.1.tar.gz

Or you can build the rpm with `easybuild`
  (obtained from http://github.com/fengy-research/easybuild)

.. code::

  $ easybuild -ba yaml-glib.spec

And the built RPMs will be in the current directory:

.. code::

  $ ls *.rpm
  yaml-glib-0.1-5.i386.rpm  yaml-glib-debuginfo-0.1-5.i386.rpm
  yaml-glib-0.1-5.src.rpm   yaml-glib-devel-0.1-5.i386.rpm

Install the package with

.. code::

  $ su -c 'rpm -U yaml-glib-0.1-5.i386.rpm \
    yaml-glib-debuginfo-0.1-5.i386.rpm \
    yaml-glib-devel-0.1-5.i386.rpm'

Example
=======

test/example-invoice.vala is an example of an invoice printer.
Example data is in test/invoice.yaml. Feed the data to the standard
input of example-invoice. The program will then parse and build the invoice,
then rewrite the model back to standard output.

Notice how PaypalAddress is extended to the original Model namespace, 
also how structs and enums are processed.

The invoice data is modified from the standard YAML example.

Documentation
=============

The documenation can be compiled from valadoc, if a valadoc 
compiler is available. No documentation is installed. It is recommended
to turn off the documentation with --disable-valadoc all the time until
valadoc is stable.

