# Sensu Go Perl Runtime Assets
[![Build Status](https://travis-ci.org/nixwiz/sensu-perl-runtime.svg?branch=master)](https://travis-ci.org/nixwiz/sensu-perl-runtime)

This project provides [Sensu Go Assets][sensu-assets] containing portable Perl
runtimes (for various platforms), based on [Sensu Ruby Runtime][sensu-ruby-runtime]
which itself was based on the excellent [ruby-install project
by postmodern][ruby-install]. In practice, this Perl runtime asset should allow
Perl-based scripts (e.g. [Sensu Community plugins][sensu-plugins]) to be
packaged as separate assets containing Perl scripts and any corresponding module
dependencies. In this way, a single shared Perl runtime may be delivered to
systems running the new Sensu Go Agent via the new Sensu's new Asset framework
(i.e. avoiding solutions that would require a Perl runtime to be redundantly
packaged with every perl-based plugin).

[sensu-assets]: https://docs.sensu.io/sensu-go/latest/reference/assets/
[sensu-ruby-runtime]: https://github.com/sensu/sensu-ruby-runtime
[ruby-install]: https://github.com/postmodern/ruby-install
[sensu-plugins]: https://github.com/sensu-plugins/

## Platform Coverage
Currently this repository only supports a subset of Linux distribution by making
use of Docker containers to build and test.  If you would like extend the coverage,
please take a look at the travisCI integration and test build scripts. We're happy
to take pull requests that extending the platform coverage.  Here's the current
platform matrix that we are testing for as of the current release:

| Asset Platform | Tested Operating Systems Docker Images |
|:---------------|:-------------------------|
|  alpine  (based on alpine:3.8)   | Alpine(3, 3.8, latest)                                      |
|  centos6 (based on centos:6)     | CentOS(6), Oracle Linux(6)                                  |
|  centos7 (based on centos:7)     | CentOS(7), Oracle Linux(7)                                  |
|  centos8 (based on centos:8)     | CentOS(8), Oracle Linux(8)                                  |
|  debian9 (based on debian:9)     | Debian(8, 9, 10), Ubuntu(14.04, 16.04, 18.04)               |

## Modules Included
The following modules (and their dependencies) are packaged as part of the runtime:
* AutoLoader
* DBI
* Data::Dumper
* DateTime
* Digest::MD5
* File::Basename
* Getopt::Long
* HTTP::Response
* IO::File
* IO::Socket::SSL
* JSON
* LWP
* LWP::Protocol::https
* LWP::UserAgent
* Module::Load
* Net::SMTP
* Net::SNMP
* Test::Simple
* Text::CSV
* Time::Zone
* WWW::Mechanize
* XML::LibXML

## To do
Need a note about adding additional modules

## Instructions
## OpenSSL Cert Dir
Please note that when using the perl runtime asset built on a target OS that is different from the build platform, you may need to explicitly set the SSL_CERT_DIR environment variable to match the target OS filesystem.  Example: CentOS configures it libssl libraries to look for certs by default in `/etc/pki/tls/certs` and Debian/Ubuntu use `/usr/lib/ssl/certs`. The CentOS runtime asset when used on a Debian system would require the use of SSL_CERT_DIR override in the check command to correctly set the cert path to `/usr/lib/ssl/certs`


Please note the following instructions:

1. Use a Docker container to build Perl, and generate a local_build Sensu Go Asset.

   ```
   $ docker build --build-arg "PERL_VERSION=5.30.1" -t sensu-perl-runtime:5.30.1-debian -f Dockerfile.debian .
   ```

2. Extract your new sensu-perl asset, and get the SHA-512 hash for your Sensu asset!

   ```
   $ mkdir dist
   $ docker run -v "$PWD/dist:/dist" sensu-perl-runtime:5.30.1-debian cp /assets/sensu-perl-runtime_local-build_perl-5.30.1_debian_linux_amd64.tar.gz /dist/
   $ shasum -a 512 dist/sensu-perl-runtime_local-build_perl-5.30.1_debian_linux_amd64.tar.gz
   ```

3. Put that asset somewhere that your Sensu agent can fetch it. Perhaps add it to the Bonsai asset index!

4. Create an asset resource in Sensu Go.

   First, create a configuration file called `sensu-perl-runtime-5.30.1-debian.json` with
   the following contents:

   ```
   {
     "type": "Asset",
     "api_version": "core/v2",
     "metadata": {
       "name": "sensu-ruby-runtime-5.30.1-debian",
       "namespace": "default",
       "labels": {},
       "annotations": {}
     },
     "spec": {
       "url": "http://your-asset-server-here/assets/sensu-perl_local-build_perl-5.30.1_debian_linux_amd64.tar.gz",
       "sha512": "4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b",
       "filters": [
         "entity.system.os == 'linux'",
         "entity.system.arch == 'amd64'",
         "entity.system.platform == 'debian'"
       ]
     }
   }
   ```

   Then create the asset via:

   ```
   $ sensuctl create -f sensu-perl-runtime-5.30.1-debian.json
   ```

4. Create a second asset containing a Perl script.

   To run a simple test using the Perl runtime asset, create another asset
   called `helloworld-v0.1.tar.gz` with a simple perl script at
   `bin/helloworld.pl`; e.g.:

   ```perl
   #!/usr/bin/env perl

   use DateTime;

   $dt = DateTime->now;

   print "Hello world! The date and time is now " . $dt->stringify() . "\n";

   ```

   _NOTE: this is a simple "hello world" example, but it shows that we have
   support for basic perl modules!_

   Compress this file into a g-zipped tarball and register this asset with
   Sensu, and then you're all ready to run some tests!

5. Create a check resource in Sensu Go.

   First, create a configuration file called `helloworld.json` with
   the following contents:

   ```
   {
     "type": "CheckConfig",
     "api_version": "core/v2",
     "metadata": {
       "name": "helloworld",
       "namespace": "default",
       "labels": {},
       "annotations": {}
     },
     "spec": {
       "command": "helloworld.pl",
       "runtime_assets": ["sensu-perl-runtime-5.30.1-debian", "helloworld-v0.1"],
       "publish": true,
       "interval": 10,
       "subscriptions": ["docker"]
     }
   }
   ```

   Then create the asset via:

   ```
   $ sensuctl create -f helloworld.json
   ```

   At this point, the `sensu-backend` should begin publishing your check
   request. Any `sensu-agent` member of the "docker" subscription should
   receive the request, fetch the Perl runtime and helloworld assets,
   unpack them, and successfully execute the `helloworld.pl` command by
   resolving the Perl shebang (`#!/usr/bin/env perl`) to the Perl runtime
   on the Sensu agent `$PATH`.
   
