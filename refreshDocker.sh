docker build -t dnam/mnemo .&& \
docker stop mnemo-server && \
docker rm mnemo-server && \
docker run --name=mnemo-server --restart=no -p 8080:80 -t -d dnam/mnemo