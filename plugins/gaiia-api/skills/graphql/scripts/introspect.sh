#!/usr/bin/env bash
# Fetch the full Gaiia GraphQL schema and cache it locally.
# Usage: ./introspect.sh [output-file]
#
# Output file defaults to .gaiia-schema.json in the current directory.
# API key is optional — the schema is publicly introspectable.
# If GAIIA_API_KEY is set (env var or .env file), it will be included in the request.

set -euo pipefail

OUTPUT="${1:-.gaiia-schema.json}"
API_URL="https://api.gaiia.com/api/v1"

# Load .env if present and GAIIA_API_KEY not already set
if [ -z "${GAIIA_API_KEY:-}" ] && [ -f ".env" ]; then
  export $(grep -E '^GAIIA_API_KEY=' .env | xargs)
fi

AUTH_HEADER=()
if [ -n "${GAIIA_API_KEY:-}" ]; then
  AUTH_HEADER=(-H "X-Gaiia-Api-Key: ${GAIIA_API_KEY}")
fi

INTROSPECTION_QUERY='{"query":"{ __schema { queryType { name } mutationType { name } types { name description kind fields(includeDeprecated: true) { name description isDeprecated deprecationReason type { name kind ofType { name kind ofType { name kind ofType { name kind } } } } args { name description type { name kind ofType { name kind ofType { name kind } } } } } inputFields { name description type { name kind ofType { name kind ofType { name kind } } } } enumValues(includeDeprecated: true) { name description isDeprecated } } } }"}'

echo "Fetching schema from $API_URL ..."
curl -sf \
  -H "Content-Type: application/json" \
  "${AUTH_HEADER[@]}" \
  -d "$INTROSPECTION_QUERY" \
  "$API_URL" \
  -o "$OUTPUT"

echo "Schema saved to $OUTPUT"
