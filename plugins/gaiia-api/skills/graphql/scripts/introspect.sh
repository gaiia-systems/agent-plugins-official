#!/usr/bin/env bash
# Fetch the full Gaiia GraphQL schema and cache it locally.
# Usage: ./introspect.sh [output-file]
#
# Output file defaults to .gaiia-schema.json in the current directory.
# API key is read from GAIIA_API_KEY env var or a .env file in the current directory.

set -euo pipefail

OUTPUT="${1:-.gaiia-schema.json}"
API_URL="https://api.gaiia.com/api/v1"

# Load .env if present and GAIIA_API_KEY not already set
if [ -z "${GAIIA_API_KEY:-}" ] && [ -f ".env" ]; then
  export $(grep -E '^GAIIA_API_KEY=' .env | xargs)
fi

if [ -z "${GAIIA_API_KEY:-}" ]; then
  echo "Error: GAIIA_API_KEY is not set." >&2
  echo "Set it via environment variable or add GAIIA_API_KEY=your_key to a .env file." >&2
  exit 1
fi

INTROSPECTION_QUERY='{"query":"{ __schema { queryType { name } mutationType { name } types { name description kind fields(includeDeprecated: true) { name description isDeprecated deprecationReason type { name kind ofType { name kind ofType { name kind ofType { name kind } } } } args { name description type { name kind ofType { name kind ofType { name kind } } } } } inputFields { name description type { name kind ofType { name kind ofType { name kind } } } } enumValues(includeDeprecated: true) { name description isDeprecated } } } }"}'

echo "Fetching schema from $API_URL ..."
curl -sf \
  -H "Content-Type: application/json" \
  -H "X-Gaiia-Api-Key: ${GAIIA_API_KEY}" \
  -d "$INTROSPECTION_QUERY" \
  "$API_URL" \
  -o "$OUTPUT"

echo "Schema saved to $OUTPUT"
