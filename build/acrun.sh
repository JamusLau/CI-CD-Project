#!/bin/sh
cd build
aclocal
autoconf
automake --add-missing
autoheader