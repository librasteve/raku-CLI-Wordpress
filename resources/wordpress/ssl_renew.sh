#!/bin/bash

DOCKER="/usr/bin/docker"
COMPOSE="/usr/bin/docker-compose"

cd /home/ubuntu/wordpress
$DOCKER container prune -f
$COMPOSE run certbot renew && $COMPOSE kill -s SIGHUP webserver
