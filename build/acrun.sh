#!/bin/sh
cd build
aclocal

# generates configure
autoconf

# generates make file
automake --add-missing

autoheader