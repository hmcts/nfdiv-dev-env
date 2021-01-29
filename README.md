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

Before starting, download the latest .env file:

```
az keyvault secret show --vault-name nfdiv-aat -o tsv --query value --name nfdiv-local-env-config > .env
```

The init script will clone the nfdiv repositories into sub-folders, start the CCD services and import the definition file. Then environment will then shut down and be ready for use.

```
./bin/init.sh
```

## Usage

Please note that the Java APIs must be assembled with `./gradlew assemble` before starting the environment.

```
docker-compose up --build
```

You can then log in to XUI going to `http://localhost:3000/`.

The following accounts have been set up:

- divorce_as_caseworker_beta@mailinator.com
- divorce_as_caseworker_solicitor@mailinator.com
- divorce_as_caseworker_bulk_scanner@mailinator.com
- divorce_as_caseworker_bulkscan@mailinator.com
- divorce_as_caseworker_superuser@mailinator.com
- divorce_as_caseworker_la@mailinator.com
- divorce_as_caseworker_admin@mailinator.com
- divorce_respondent_solicitor@mailinator.com
- TEST_SOLICITOR@mailinator.com

The password for these accounts is `Testing1234`

### Updating the CCD definition file

Import changes to the CCD definition file by running:

```
./bin/ccd-import-definition.sh
```

