#!/usr/bin/env bash
# Show all fields and their types/descriptions for a given GraphQL type.
# Usage: ./describe_type.sh <TypeName> [schema-file]

set -euo pipefail

TYPE_NAME="${1:-}"
SCHEMA="${2:-.gaiia-schema.json}"

if [ -z "$TYPE_NAME" ]; then
  echo "Usage: $0 <TypeName> [schema-file]" >&2
  exit 1
fi

if [ ! -f "$SCHEMA" ]; then
  echo "Schema file not found: $SCHEMA" >&2
  echo "Run introspect.sh first to fetch the schema." >&2
  exit 1
fi

jq --arg name "$TYPE_NAME" '
  .data.__schema.types[]
  | select(.name == $name)
  | {
      name: .name,
      kind: .kind,
      description: .description,
      fields: (
        .fields // .inputFields // []
        | map({
            name: .name,
            description: .description,
            deprecated: .isDeprecated,
            deprecation_reason: .deprecationReason,
            type: (
              .type
              | if .kind == "NON_NULL" or .kind == "LIST" then
                  (if .ofType.kind == "NON_NULL" or .ofType.kind == "LIST" then
                    .ofType.ofType.name
                  else
                    .ofType.name
                  end)
                else
                  .name
                end
            ),
            args: (
              .args // []
              | map({ name: .name, description: .description, type: .type.name })
            )
          })
      ),
      enum_values: (
        .enumValues // []
        | map({ name: .name, description: .description })
      )
    }
' "$SCHEMA"
