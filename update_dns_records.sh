#!/bin/bash

# Test if authorization token is available in env
if [ -z "$GANDI_LIVEDNS_API_KEY" ]; then
  echo "GANDI_LIVEDNS_API_KEY is not set"
  exit 1
fi

BASE_URL="https://api.gandi.net/v5/livedns/domains/chalnot.fr/records"
AUTHORIZATION_HEADER="authorization: Bearer $GANDI_LIVEDNS_API_KEY"
CONTENT_TYPE_HEADER="content-type: application/json"
# Get the current IP address from https://api.ipify.org
IP=$(curl -s https://api.ipify.org)

# Check if the registered IP address is valid
RESPONSE=$(curl -s -X GET "$BASE_URL/@/A" -H "$AUTHORIZATION_HEADER" -H "$CONTENT_TYPE_HEADER")
CURRENT_IP=$(echo "$RESPONSE" | jq -r '.rrset_values[0]')

# Compare the registered IP address with the actual IP address
if [ "$IP" == "$CURRENT_IP" ]; then
  exit 0
fi

# Update the A record for the domain if the IP address has changed
DATA="{\"rrset_values\":[\"$IP\"],\"rrset_ttl\":10800}"

check_response() {
  local response=$1
  if [ "$response" != '{"message":"DNS Record Created"}' ]; then
    echo "Error: Unexpected response: $response"
    exit 1
  fi
}

RESPONSE=$(curl -s -X PUT "$BASE_URL/@/A" -H "$AUTHORIZATION_HEADER" -H "$CONTENT_TYPE_HEADER" -d "$DATA")
check_response "$RESPONSE"

RESPONSE=$(curl -s -X PUT "$BASE_URL/*/A" -H "$AUTHORIZATION_HEADER" -H "$CONTENT_TYPE_HEADER" -d "$DATA")
check_response "$RESPONSE"

echo "DNS records updated successfully"

# Check if Pushover token and user key are available in env

if [ -z "$PUSHOVER_TOKEN" ] || [ -z "$PUSHOVER_USER_KEY" ]; then
    exit 0
fi

curl -s \
  --form-string "token=$PUSHOVER_TOKEN" \
  --form-string "user=$PUSHOVER_USER_KEY" \
  --form-string "message=IP address updated: $IP" \
  https://api.pushover.net/1/messages.json

