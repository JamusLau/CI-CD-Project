#!/bin/sh
aclocal

# generates make file
automake --add-missing

# generates configure
autoconf

autoheader