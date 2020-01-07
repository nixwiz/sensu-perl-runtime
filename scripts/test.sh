#!/bin/sh
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
tar xzf /dist/$asset_filename
LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" PERL5LIB="/build/lib:$PERL5LIB" /build/bin/perl /scripts/test_ssl_url.pl

