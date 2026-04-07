#!/usr/bin/env bash
# Search for mutations by keyword in name or description.
# Usage: ./search_mutations.sh <term> [schema-file]

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
  | select(.name == "Mutation")
  | .fields // []
  | map(select(
      (.name | ascii_downcase | contains($term | ascii_downcase)) or
      (.description // "" | ascii_downcase | contains($term | ascii_downcase))
    ))
  | map({
      mutation: .name,
      description: .description,
      deprecated: .isDeprecated,
      args: (
        .args // []
        | map({
            name: .name,
            description: .description,
            type: (
              .type
              | if .kind == "NON_NULL" then .ofType.name else .name end
            )
          })
      ),
      returns: .type.name
    })
' "$SCHEMA"
