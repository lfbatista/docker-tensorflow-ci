THIS_FILE := $(lastword $(MAKEFILE_LIST))
.PHONY: help build up start down destroy stop restart logs ps images migrate collectstatic
help:
	make -pRrq  -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
build:
	docker build -t deployment .
pull:
	docker pull docker.pkg.github.com/lfbatista/docker-tensorflow-ci/deployment:latest
run:
	docker run -d --name deployment -p 80:5000 -e PORT=5000 docker.pkg.github.com/lfbatista/docker-tensorflow-ci/deployment:latest
bash:
	docker exec -it deployment bash
stop:
	docker stop deployment
remove:
	docker rm -f deployment
restart:
	docker rm -f deplyment
	docker run -d --name deployment -p 80:5000 -e PORT=5000 docker.pkg.github.com/lfbatista/docker-tensorflow-ci/deployment:latest
logs:
	docker logs -f deployment --tail=100
