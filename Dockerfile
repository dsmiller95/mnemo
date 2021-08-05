FROM httpd:2.4

RUN apt-get update && apt-get install -y dos2unix make gcc cpanminus
RUN cpanm Data::UUID

RUN mkdir /usr/src/mnemo
WORKDIR /usr/src/mnemo

COPY ./ ./

RUN dos2unix ./install.sh
WORKDIR /usr/src/mnemo/cgi-bin
RUN find . -type f -print0 | xargs -0 dos2unix 
WORKDIR /usr/src/mnemo

RUN apt-get --purge remove -y dos2unix make gcc cpanminus && rm -rf /var/lib/apt/lists/*

RUN sh install.sh



