#!/bin/sh
: ${IMAGENAME:?}
: ${PLATFORM:?}
: ${BUILD:?}
set -x    
docker build -t $IMAGENAME ${NOCACHE:+--no-cache} \
          --build-arg OSVERSION=$OSVERSION \
          --build-arg PIES_TAG=$PIES_TAG \
          --build-arg XENV_TAG=$XENV_TAG \
	  -f ${PLATFORM}/Dockerfile \
          tree
