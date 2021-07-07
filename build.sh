#!/bin/sh
: ${IMAGENAME:?}
: ${PLATFORM:?}
: ${BUILD:?}
: ${VERSION:?}
set -x
docker build -t $IMAGENAME ${NOCACHE:+--no-cache} \
          --build-arg VERSION=$VERSION \
          --build-arg OSVERSION=$OSVERSION \
          --build-arg PIES_TAG=$PIES_TAG \
	  --build-arg PIES_VERSION=${PIES_VERSION:-$PIES_TAG} \
          --build-arg XENV_TAG=$XENV_TAG \
	  --build-arg XENV_VERSION=${XENV_VERSION:-$XENV_TAG} \
	  --build-arg CREATEDTIME=$(date --utc +'%Y-%m-%dT%H:%M:%SZ') \
	  -f ${PLATFORM}/Dockerfile \
          tree
