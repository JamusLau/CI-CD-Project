#!/bin/sh
cd build
aclocal

# generates make file
automake --add-missing

# generates configure
autoconf

autoheader