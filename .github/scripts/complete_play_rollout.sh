#!/bin/bash
# Sets current Google Play release from 99.999% to 100%
# Needs SERVICE_ACCOUNT_JSON and PACKAGE_NAME.
set -eo pipefail

# access token for the service account, from a signed JWT:
# https://developers.google.com/identity/protocols/oauth2/service-account#httprest
b64url() { openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }
email="$(jq -r .client_email <<< "$SERVICE_ACCOUNT_JSON")"
now="$(date +%s)"
header="$(echo -n '{"alg":"RS256","typ":"JWT"}' | b64url)"
claims="$(echo -n "{\"iss\":\"$email\",\"scope\":\"https://www.googleapis.com/auth/androidpublisher\",\"aud\":\"https://oauth2.googleapis.com/token\",\"iat\":$now,\"exp\":$((now + 600))}" | b64url)"
signature="$(echo -n "$header.$claims" | openssl dgst -sha256 -sign <(jq -r .private_key <<< "$SERVICE_ACCOUNT_JSON") | b64url)"
token="$(curl -sS --fail-with-body https://oauth2.googleapis.com/token \
  -d grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
  -d assertion="$header.$claims.$signature" | jq -r .access_token)"
echo "::add-mask::$token"

# Play edit: read the production track, set the release in progress to completed, commit
api="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$PACKAGE_NAME/edits"
play() { curl -sS --fail-with-body -H "Authorization: Bearer $token" "$@"; }

edit="$(play -X POST "$api" | jq -r .id)"
track="$(play "$api/$edit/tracks/production")"
jq -r '.releases[]? | "Production: \(.name) \(.status)"' <<< "$track"
release="$(jq -c '.releases[]? | select(.status == "inProgress")' <<< "$track")"
if [ -z "$release" ]; then
  echo "Nothing to complete"
  exit 0
fi

echo "Completing $(jq -r .name <<< "$release")"
completed="$(jq -c 'del(.userFraction) | .status = "completed"' <<< "$release")"
play -X PUT -H 'Content-Type: application/json' -d "{\"track\":\"production\",\"releases\":[$completed]}" \
  "$api/$edit/tracks/production" > /dev/null
play -X POST "$api/$edit:commit" > /dev/null
