# Sensu Go Perl Runtime Assets
![release](https://github.com/nixwiz/sensu-go-fatigue-check-filter/workflows/release/badge.svg)

This project provides [Sensu Go Assets][sensu-assets] containing portable Perl
runtimes (for various platforms), based on [Sensu Ruby Runtime][sensu-ruby-runtime]
which itself was based on the excellent [ruby-install project
by postmodern][ruby-install]. In practice, this Perl runtime asset should allow
Perl-based scripts to be packaged as separate assets containing Perl scripts and
any corresponding module dependencies. In this way, a single shared Perl runtime
may be delivered to systems running the Sensu Go Agent via the Sensu's Asset framework
(i.e. avoiding solutions that would require a Perl runtime to be redundantly
packaged with every perl-based plugin).

[sensu-assets]: https://docs.sensu.io/sensu-go/latest/reference/assets/
[sensu-ruby-runtime]: https://github.com/sensu/sensu-ruby-runtime
[ruby-install]: https://github.com/postmodern/ruby-install

## Platform Coverage
Currently this repository only supports a subset of Linux distribution by making
use of Docker containers to build and test.  If you would like extend the coverage,
please take a look at the Github Action and test build scripts. I'm happy
to take pull requests that extending the platform coverage.  Here's the current
platform matrix that we are testing for as of the current release:

| Asset Platform                    | Tested Operating Systems Docker Images        |
|:----------------------------------|:----------------------------------------------|
|  alpine  (based on alpine:3.8)    | Alpine(3, 3.8, latest)                        |
|  centos7 (based on centos:7)      | CentOS(7), Oracle Linux(7)                    |
|  rocky8  (based on rockylinux:8)  | Rocky Linux(8), Oracle Linux(8)               |
|  amzn2   (Based on amazonlinux:2) | Amazon Linux(2)                               |
|  debian9 (based on debian:9)      | Debian(8, 9, 10), Ubuntu(14.04, 16.04, 18.04) |

## Modules Included

The following modules (and their dependencies) are packaged as part of the runtime:
* AutoLoader
* DBI
* Data::Dumper
* DateTime
* Digest::MD5
* File::Basename
* File::Slurp
* Getopt::Long
* HTTP::Response
* IO::File
* IO::Socket::SSL
* JSON
* JSON::XS
* LWP
* LWP::Protocol::https
* LWP::UserAgent
* Module::Load
* Net::SMTP
* Net::SNMP<sup>1</sup>
* Test::Simple
* Text::CSV
* Time::Zone
* WWW::Mechanize
* XML::LibXML

1. The Net::SNMP module is not included for Alpine as I gave up on trying to get it to work in the Docker build environment.

## Using the assets (non-Bonsai)

### Dowloadable releases

Releases are currently available on [Github][https://github.com/nixwiz/sensu-perl-runtime/releases].

### Building the assets locally

1. Use a Docker container to build Perl, and generate a local_build Sensu Go Asset.

   ```
   $ docker build --build-arg "PERL_VERSION=5.34.0" -t sensu-perl-runtime:5.34.0-debian -f Dockerfile.debian .
   ```

2. Extract your new sensu-perl asset, and get the SHA-512 hash for your Sensu asset!

   ```
   $ mkdir dist
   $ docker run -v "$PWD/dist:/dist" sensu-perl-runtime:5.34.0-debian cp /assets/sensu-perl-runtime_local-build_perl-5.34.0_debian_linux_amd64.tar.gz /dist/
   $ shasum -a 512 dist/sensu-perl-*
   ```
### Using the assets

1. Put that asset somewhere that your Sensu agent can fetch it. Perhaps add it to the Bonsai asset index!

2. Create an asset resource in Sensu Go.

   First, create a configuration file called `sensu-perl-runtime-5.34.0-debian.json` with
   the following contents:

   ```
   {
     "type": "Asset",
     "api_version": "core/v2",
     "metadata": {
       "name": "sensu-ruby-runtime-5.34.0-debian",
       "namespace": "default",
       "labels": {},
       "annotations": {}
     },
     "spec": {
       "url": "http://your-asset-server-here/assets/sensu-perl_local-build_perl-5.34.0_debian_linux_amd64.tar.gz",
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
   $ sensuctl create -f sensu-perl-runtime-5.34.0-debian.json
   ```

3. Create a second asset containing a Perl script.

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

4. Create a check resource in Sensu Go.

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
       "runtime_assets": ["sensu-perl-runtime-5.34.0-debian", "helloworld-v0.1"],
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
   
## Additional modules

TBD on how to make use of modules not currently included.
