#!/bin/sh
docker ps -aq | xargs docker stop
docker container prune -f