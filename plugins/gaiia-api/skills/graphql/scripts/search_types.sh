#!/usr/bin/env bash
# Search for types and fields in the cached schema by keyword.
# Usage: ./search_types.sh <term> [schema-file]
#
# Searches type names, type descriptions, field names, and field descriptions.
# Excludes built-in GraphQL introspection types (__*).

set -euo pipefail

TERM="${1:-}"
SCHEMA="${2:-.gaiia-schema.json}"

if [ -z "$TERM" ]; then
  echo "Usage: $0 <search-term> [schema-file]" >&2
  exit 1
fi

if [ ! -f "$SCHEMA" ]; then
  echo "Schema file not found: $SCHEMA" >&2
  echo "Run introspect.sh first to fetch the schema." >&2
  exit 1
fi

jq --arg term "$TERM" '
  .data.__schema.types[]
  | select(.name | startswith("__") | not)
  | select(
      (.name | ascii_downcase | contains($term | ascii_downcase)) or
      (.description // "" | ascii_downcase | contains($term | ascii_downcase)) or
      (.fields // [] | any(
        (.name | ascii_downcase | contains($term | ascii_downcase)) or
        (.description // "" | ascii_downcase | contains($term | ascii_downcase))
      ))
    )
  | {
      type: .name,
      kind: .kind,
      description: .description,
      matching_fields: (
        .fields // []
        | map(select(
            (.name | ascii_downcase | contains($term | ascii_downcase)) or
            (.description // "" | ascii_downcase | contains($term | ascii_downcase))
          ))
        | map({ name: .name, description: .description, type: .type.name })
      )
    }
' "$SCHEMA"
