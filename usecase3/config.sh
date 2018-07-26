#!/bin/bash
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export DOCKER_LABEL="minioclient"
export DOCKER_TAG="minio/mc"

export CONTAINER_NAME="minioclient"
export DOCKER_NEW_MINIO_TAG="gpdb-minio/mc"
