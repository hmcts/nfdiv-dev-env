# No Fault Divorce Development Environment

A docker based development environment for the no fault divorce services.

## Requirements

This is designed to work on Mac or Linux but has not been tested on Windows.

The following packages are required:
 - docker
 - docker-compose
 - azure-cli
 - postgres-client

Note that a VPN is required as this environment uses multiple services in the AAT environment. 

## Set up

Before starting, ask a developer in the No Fault Divorce team for a `.env` file.

The init script will clone the nfdiv repositories into sub-folders, start the CCD services and import the definition file. Then environment will then shut down and be ready for use.

```
./bin/init.sh
```

## Usage

Please note that the Java APIs must be assembled with `./gradlew assemble` before starting the environment.

```
docker-compose up
```

### Updating the CCD definition file

Import changes to the CCD definition file by running:

```
./bin/import-ccd-definition.sh
```

