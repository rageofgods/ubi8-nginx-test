# ubi8-nginx-test
Simple proof of concept

docker build . -t test:test
docker run -d -p 8080:80 test:test
