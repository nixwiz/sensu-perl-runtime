#!/bin/sh

install_tar() {
  # Please don't look at me, I'm hideous
  if type yum > /dev/null 2>&1; then
    yum -y install tar gzip
  elif type apt-get > /dev/null 2>&1; then
    apt-get install -y tar
  elif type apk > /dev/null 2>&1; then
    apk --no-cache add tar
  fi
}

echo "Test Script:"
echo "  Asset Platform:  ${platform}"
echo "  Target Platform: ${test_platform}"
echo "  Asset Tarball:   ${asset_filename}"
if [ -z "$asset_filename" ]; then
  echo "Asset is empty"
  exit 1
fi
mkdir -p /build
cd /build
# Some Docker images (I'm talking to you Oracle Linux) don't
# include tar, so go find it
if [ ! -x /bin/tar ] && [ ! -x /usr/bin/tar ]; then
  install_tar
fi
tar xzf /dist/$asset_filename
LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/perl /scripts/test_ssl_url.pl

