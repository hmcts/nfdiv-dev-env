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

Also, you will need access to azure key vault. Please contact a member of No Fault Divorce team to gain access.

## Set up

Before starting, download the latest .env file:

```
az keyvault secret show --vault-name nfdiv-aat -o tsv --query value --name nfdiv-local-env-config | base64 -d > .env
```

The init script will clone the nfdiv repositories into sub-folders, start the CCD services and import the definition file. Then environment will then shut down and be ready for use.

```
./bin/init.sh
```

## Usage

Please note that the Java APIs must be assembled with `./gradlew assemble` before starting the environment.

```
./bin/start.sh
```

You can then log in to XUI going to `http://localhost:3000/`.

To stop docker containers execute below script. This will bring down all docker containers.

```
./bin/stop.sh
```

The following accounts have been set up:

- TEST_CASE_WORKER_USER@mailinator.com
- DivCitizenUser@AAT.com
- DivCaseWorkerUser@AAT.com  
- TEST_SOLICITOR@mailinator.com

The password for these accounts is in your .env file.

### Updating the CCD definition file

Import changes to the CCD definition file by running:

```
./bin/ccd-import-definition.sh
```

