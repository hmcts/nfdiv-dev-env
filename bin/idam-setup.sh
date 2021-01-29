#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

IDAM_URI="http://localhost:5000"
REDIRECTS=("http://localhost:3001/oauth2/callback" "https://div-pfe-aat.service.core-compute-aat.internal/authenticated")
REDIRECTS_STR=$(printf "\"%s\"," "${REDIRECTS[@]}")
REDIRECT_URI="[${REDIRECTS_STR%?}]"
CLIENT_ID="divorce"
CLIENT_SECRET=${OAUTH2_CLIENT_SECRET}
ROLES_ARR=("citizen" "claimant" "ccd-import" "caseworker-divorce" "caseworker" "caseworker-divorce-courtadmin_beta" "caseworker-divorce-systemupdate" "caseworker-divorce-superuser" "caseworker-divorce-pcqextractor" "caseworker-divorce-courtadmin-la" "caseworker-divorce-bulkscan" "caseworker-divorce-courtadmin" "caseworker-divorce-solicitor" "caseworker-caa" "payment")
ROLES_STR=$(printf "\"%s\"," "${ROLES_ARR[@]}")
ROLES="[${ROLES_STR%?}]"

AUTH_TOKEN=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=idamOwner@hmcts.net&password=Ref0rmIsFun" | docker run --rm --interactive stedolan/jq -r .api_auth_token)
HEADERS=(-H "Authorization: AdminApiAuthToken ${AUTH_TOKEN}" -H "Content-Type: application/json")

# Create a client
curl -s -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "'${CLIENT_ID}'", "label": "'${CLIENT_ID}'", "oauth2ClientId": "'${CLIENT_ID}'", "oauth2ClientSecret": "'${CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "openid profile roles", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'

# Create roles in idam
for role in "${ROLES_ARR[@]}"; do
  curl -s -XPOST ${IDAM_URI}/roles "${HEADERS[@]}" \
    -d '{"id": "'${role}'","name": "'${role}'","description": "'${role}'","assignableRoles": [],"conflictingRoles": []}'
done

# Assign all the roles to the client
curl -s -XPUT "${HEADERS[@]}" ${IDAM_URI}/services/${CLIENT_ID}/roles -d "${ROLES}"

./bin/idam-create-user.sh citizen,claimant $IDAM_CITIZEN_USERNAME $IDAM_CITIZEN_PASSWORD citizens
./bin/idam-create-user.sh caseworker,caseworker-divorce $IDAM_CASEWORKER_USERNAME $IDAM_CASEWORKER_PASSWORD caseworker
./bin/idam-create-user.sh caseworker,caseworker-divorce,caseworker-divorce-courtadmin_beta $IDAM_TEST_CASEWORKER_USERNAME $IDAM_TEST_CASEWORKER_PASSWORD caseworker
./bin/idam-create-user.sh caseworker,caseworker-divorce,caseworker-divorce-solicitor,caseworker-divorce-superuser $IDAM_TEST_SOLICITOR_USERNAME $IDAM_TEST_SOLICITOR_PASSWORD caseworker
./bin/idam-create-user.sh ccd-import $CCD_DEFINITION_IMPORTER_USERNAME $CCD_DEFINITION_IMPORTER_PASSWORD Default
