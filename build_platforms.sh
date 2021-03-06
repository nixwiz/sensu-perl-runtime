#!/bin/bash

mkdir -p dist
mkdir -p assets
mkdir -p scripts

# Debian platforms
platform="debian9" test_platforms="debian:8 debian:9 debian:10 ubuntu:14.04 ubuntu:16.04 ubuntu:18.04" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi

# Alpine platform
platform="alpine" test_platforms="alpine:latest alpine:3 alpine:3.8" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi
platform="alpine3.8" test_platforms="alpine:latest alpine:3 alpine:3.8" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi

# RHEL and derivative platforms
platform="centos6" test_platforms="centos:6 oraclelinux:6" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi

platform="centos7" test_platforms="centos:7 oraclelinux:7" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi

platform="centos8" test_platforms="centos:8 oraclelinux:8" ./build_and_test_platform.sh
retval=$?
if [[ retval -ne 0 ]]; then
  exit $retval
fi

