#!/bin/bash

# Get the absolute path of the project
# c.f http://stackoverflow.com/a/246128
rootDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $rootDir

# Build the docker image
docker build -t timendash $rootDir

# Run it on the port 3030
docker run -p 3030:3030 timendash
