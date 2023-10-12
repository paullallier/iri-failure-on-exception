#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

docker run -d --name quick-demo \
    -v "$SCRIPT_DIR"/..:/var/www/quick-demo:Z --pull always -p 127.0.0.1:8080:80 \
    paullallier/quick-demo:latest

docker exec quick-demo touch /var/log/apache2/xdebug.log
docker exec quick-demo chmod 777 /var/log/apache2/xdebug.log

