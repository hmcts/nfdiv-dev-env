# No Fault Divorce Development Environment

A docker based development environment for the no fault divorce services.

## Requirements

This is designed to work on Mac or Linux but has not been tested on Windows.

The following packages are required:
 - docker
 - docker-compose
 - azure-cli
 - postgres-client

Note that this environment uses IDAM in AAT so a VPN is required. 

## Set up

When first creating the environment, log in to azure to access the container registry:

```
az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
```

Then run:

```
./bin/init.sh
```

This will clone the nfdiv repositories into sub-folders, start the CCD services and import the definition file. Then environment will then shut down and be ready for use.

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

