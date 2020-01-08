#!/bin/bash

ignore_errors=0
perl_version=5.30.1
asset_version=${TRAVIS_TAG:-local-build}
asset_filename=sensu-perl-runtime_${asset_version}_perl-${perl_version}_${platform}_linux_amd64.tar.gz
asset_image=sensu-perl-runtime-${perl_version}-${platform}:${asset_version}

if [ "${asset_version}" = "local-build" ]; then
  echo "Local build"
  ignore_errors=1
fi


echo "Platform: ${platform}"
echo "Check for asset file: ${asset_filename}"
if [ -f "$PWD/dist/${asset_filename}" ]; then
  echo "File: "$PWD/dist/${asset_filename}" already exists!!!"
  [ $ignore_errors -eq 0 ] && exit 1  
else
  echo "Check for docker image: ${asset_image}"
  if [[ "$(docker images -q ${asset_image} 2> /dev/null)" == "" ]]; then
    echo "Docker image not found...we can build"
    echo "Building Docker Image: sensu-perl-runtime:${perl_version}-${platform}"
    if [ -n "$TRAVIS_TAG" ]; then
      docker build --build-arg "PERL_VERSION=$perl_version" --build-arg "ASSET_VERSION=$asset_version" --build-arg "MAKE_TEST_CMD=true" --build-arg "CPANM_TEST_FLAG=--notest" -t ${asset_image} -f Dockerfile.${platform} .
    else
      docker build --build-arg "PERL_VERSION=$perl_version" --build-arg "ASSET_VERSION=$asset_version" -t ${asset_image} -f Dockerfile.${platform} .
    fi
    echo "Making Asset: /assets/sensu-perl-runtime_${asset_version}_perl-${perl_version}_${platform}_linux_amd64.tar.gz"
    docker run --rm -v "$PWD/dist:/dist" ${asset_image} cp /assets/${asset_filename} /dist/
  else
    echo "Image already exists!!!"
    [ $ignore_errors -eq 0 ] && exit 1  
  fi
fi


test_arr=($test_platforms)
for test_platform in "${test_arr[@]}"; do
  echo "Test: ${test_platform}"
  docker run --rm -e platform -e test_platform=${test_platform} -e asset_filename=${asset_filename} -v "$PWD/scripts/:/scripts" -v "$PWD/dist:/dist" ${test_platform} /scripts/test.sh
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "!!! Error testing ${asset_filename} on ${test_platform}"
    exit $retval
  fi
done

if [ -z "$TRAVIS_TAG" ]; then exit 0; fi
if [ -z "$DOCKER_USER" ]; then exit 0; fi
if [ -z "$DOCKER_PASSWORD" ]; then exit 0; fi

docker_asset=${TRAVIS_REPO_SLUG}-${perl_version}-${platform}:${asset_version}

echo "Docker Hub Asset: ${docker_asset}"
echo "preparing to tag and push docker hub asset"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin

docker tag ${asset_image} ${docker_asset}
docker push ${docker_asset}

ver=${asset_version%+*}
prefix=${ver%-*}
prerel=${ver/#$prefix}
if [ -z "$prerel" ]; then 
  echo "tagging as latest asset"
  latest_asset=${TRAVIS_REPO_SLUG}-${perl_version}-${platform}:latest
  docker tag ${asset_image} ${latest_asset}
  docker push ${latest_asset}
fi

