FROM httpd:2.4

RUN mkdir /usr/src/mnemo
WORKDIR /usr/src/mnemo

COPY ./ ./

RUN sh install.sh



