#!/bin/bash

cp --preserve=mode -R ./cgi-bin/* /usr/local/apache2/cgi-bin
cp -r ./htdocs/* /usr/local/apache2/htdocs
cp ./httpd.conf /usr/local/apache2/conf/httpd.conf

