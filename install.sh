#!/bin/bash

chmod --recursive 777 ./cgi-bin/mnemo_ops
cp --preserve=mode -R ./cgi-bin/* /usr/local/apache2/cgi-bin

mkdir /home/mnemo_ops # prepare to mount exteral folder here
cp -R ./htdocs/* /usr/local/apache2/htdocs
cp ./httpd.conf /usr/local/apache2/conf/httpd.conf

