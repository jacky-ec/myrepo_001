#!/bin/bash -ex

tag=$(echo ${PWD} | tr / - | cut -b2- | tr A-Z a-z)
groups=$(id -G | xargs -n1 echo -n " --group-add ")
params="-v ${HOME}:${HOME} -v ${PWD}:${PWD} --rm -w ${PWD} -u"$(id -u):$(id -g)" $groups -v/etc/passwd:/etc/passwd:ro -v/etc/group:/etc/group:ro ${tag}"

docker build --tag=${tag} docker

docker run -it $params $@
