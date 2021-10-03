#!/bin/bash

# Rating service
docker build -t ratings .

docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

# Details service
docker build -t details .

docker run -d --name details -p 8081:8081 details

# Review service
docker build -t reviews .

docker run -d --name reviews -p :8082:8082 --link ratings:ratings \
    -e ENABLE_RATINGS=true -e 'RATINGS_SERVICE=http://ratings:8080' reviews

# Productpage service
docker build -t productpage .

docker run -d --name productpage -p 8083:8083 --link details:details --link ratings:ratings --link reviews:reviews \
    -e 'DETAILS_HOSTNAME=http://details:8081' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'REVIEWS_HOSTNAME=http://reviews:9080' productpage

