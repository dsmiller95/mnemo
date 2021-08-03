#!/bin/bash

# I use `cat` to avoid changing ownership of the target file.
cat cgi-bin/mnemo > /usr/local/apache2/cgi-bin/mnemo
cp -r ./htdocs /usr/local/apache2/htdocs


