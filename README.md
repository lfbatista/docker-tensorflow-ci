## Docker deployment with GitHub Actions
![Docker CI](https://github.com/lfbatista/docker-tensorflow-ci/workflows/Docker%20CI/badge.svg)
![Docker Image Version](https://img.shields.io/docker/v/batistaluisfilipe/docker-tensorflow-ci)
[![Docker Image Size](https://img.shields.io/docker/image-size/batistaluisfilipe/docker-tensorflow-ci)](https://hub.docker.com/r/batistaluisfilipe/docker-tensorflow-ci)
[![Docker layers](https://img.shields.io/microbadger/layers/batistaluisfilipe/docker-tensorflow-ci)](https://hub.docker.com/r/batistaluisfilipe/docker-tensorflow-ci)

This repo aims to containerise, build and deploy the present app into production.
For this use case, the app is being hosted on Heroku.
The deployment process is triggered by push and pull request events.

The main workflow `docker-publish.yml` contains 4 jobs:
- model: downloads and pushes a new [TensorFlow model](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) to the repo
- test: builds the Docker image (depends on model)
- push: builds and publishes a new Docker image (depends on test)
- deploy: builds, pushes and deploys a new Docker image to Heroku (depends on test)

### How to use this image
```bash
$ docker pull docker.pkg.github.com/lfbatista/docker-tensorflow-ci/deployment:latest
$ docker run -d --name deployment -p 80:5000 -e PORT=5000 
docker.pkg.github.com/lfbatista/docker-tensorflow-ci/deployment:latest
$ # or
$ git clone https://github.com/lfbatista/docker-tensorflow-ci
$ cd docker-tensorflow-ci
$ docker build -t deployment .
$ docker run -d --name deployment -p 80:5000 -e PORT=5000 deployment:latest
```
To have more detailed logs, please use `Dockerfile.verbose`.

### API testing
```bash
$ curl --form 'imageData=@/path/to/some/image.jpeg' <ip-address>/image
$ # The url endpoint receives multiple urls:
$ curl --data '[{"url": "http://farm5.staticflickr.com/4022/4633531130_9834db28b2_z.jpg"},
{"url": "https://farm1.staticflickr.com/101/375620230_e8f6da6e6d_z.jpg"}' <ip-address>/url
```
