#!/bin/bash
#
# Description : start a docker with parameter or reuse the existent docker
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2015-11-16
# Licence : GPL v3.
###############################################################################

# TODO : Voir pour mettre les variables globale entre run.sh , build.sh 
DOCKER_IMG=linux202-x3:ubuntu_base
DOCKER_NAME=ubuntu_x3-base
PORT_FORWARD=" -p 127.0.0.1:2222:22 -p 8080:80"
EXPORT_DIR="" # ex: -v /home/bob:/docker/home/bob"

# Check if the docker actually running
OUTPUT_RUN=$(docker run -d  -h dck-$USER.example.com --privileged --name $DOCKER_NAME $EXPORT_DIR $PORT_FORWARD $DOCKER_IMG 2>&1)
RET_VAL_DOCKER_RUN=$?

if [ $RET_VAL_DOCKER_RUN -ne 0 ] ;then
    # Docker container name already use
    if echo $OUTPUT_RUN | grep -q "is already in use" ; then
        if  docker ps | egrep -q "$DOCKER_NAME\s*$"  ; then
            echo " Your docker $DOCKER_NAME alreay running "
            echo " You can use $ docker attach $DOCKER_NAME to establish a connection"
            exit 0
        fi
        echo "Docker name alreay use , I restart the old container"
        OUTPUT_START=$(docker start $DOCKER_NAME 2>&1)
        RET_VAL_START_DOCKER=$?
        echo " You can use $ docker attach $DOCKER_NAME to establish a connection"
        exit $?
    fi

    # If the Docker not already running it's an other problem not alreay take in charge by this scrypt
    echo $OUTPUT_RUN 
    exit $RET_VAL_DOCKER_RUN
fi
