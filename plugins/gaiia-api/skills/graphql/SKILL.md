---
name: graphql
description: Explore and query the Gaiia GraphQL API (https://api.gaiia.com/api/v1). Use when a developer wants to build, test, or understand GraphQL queries or mutations against the Gaiia OSS/BSS platform API. Covers iterative schema exploration, query construction, mutation discovery, and API execution. Trigger on requests like "query the Gaiia API", "find subscriptions for customer X", "what mutations exist for billing", "explore the Gaiia schema", or any task involving the Gaiia GraphQL API.
---

# Gaiia API

GraphQL API at `https://api.gaiia.com/api/v1`. Root query type: `Query`. Root mutation type: `Mutation`.

## Reference Docs

Load these as needed:

- **[references/setup.md](references/setup.md)** — API key configuration. Load when the user hasn't set up their key or hits auth errors.
- **[references/pagination.md](references/pagination.md)** — Relay cursor pagination, `Connection`/`PageInfo` types, iterating all pages. Load when building any query that returns a list.
- **[references/errors.md](references/errors.md)** — Mutation errors live in `data.*.errors[]`, not top-level `errors`. Load when handling mutation responses or debugging errors.
- **[references/rate-limits.md](references/rate-limits.md)** — Leaky bucket, 500 point cap, response headers, `RATE_LIMITED` error. Load when making batch requests or debugging rate limit errors.
- **[references/global-ids.md](references/global-ids.md)** — Global ID format (`type_<base58uuid>`), UUID↔GlobalID conversion in JS and Python. Load when working with IDs or bridging Snowflake UUIDs to API calls.

## Scripts

All scripts live in `${CLAUDE_SKILL_DIR}/scripts/`. Make them executable once:

```bash
chmod +x ${CLAUDE_SKILL_DIR}/scripts/*.sh
```

| Script | Purpose |
|---|---|
| `introspect.sh [output-file]` | Fetch and cache the full schema |
| `search_types.sh <term> [schema]` | Find types/fields matching a keyword |
| `describe_type.sh <TypeName> [schema]` | Show all fields + descriptions for a type |
| `search_mutations.sh <term> [schema]` | Find mutations matching a keyword |

Schema defaults to `.gaiia-schema.json` in the current directory if not specified.

## Iterative Query-Building Workflow

Follow this loop to build any query from scratch. **Always explore before writing a query** — never guess type or field names.

### Step 1: Fetch the schema (once per session)

Check if `.gaiia-schema.json` exists. If not (or if the user wants a refresh):

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/introspect.sh
```

If a cached schema exists, ask: "I found a cached schema — should I use it or refresh from the API?"

### Step 2: Search for relevant types

Search by domain keyword to find where to start:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/search_types.sh "subscription"
```

**Show results to the user and confirm** which type looks right before proceeding. Example: "I found these types matching 'subscription': `Subscription`, `SubscriptionItem`, `SubscriptionStatus`. Which one should I explore further?"

### Step 3: Describe the chosen type

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh Subscription
```

Review fields. If a field's type looks relevant but unfamiliar, describe that type too:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh SubscriptionItem
```

Repeat until you understand the shape of data needed.

### Step 4: Find the query entry point

Search the `Query` type for the relevant root field:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh Query
```

### Step 5: Build and execute the query

Use only field names confirmed from schema exploration. Execute with curl:

```bash
curl -s \
  -H "Content-Type: application/json" \
  -H "X-Gaiia-Api-Key: ${GAIIA_API_KEY}" \
  -d '{"query": "{ ... }"}' \
  https://api.gaiia.com/api/v1 | jq .
```

If the query returns errors, check field names against `describe_type.sh` output — do not guess corrections.

### Step 6: Iterate

Use results to refine. If a field returns an ID to another type, describe that type and expand the query. Repeat steps 3–5 as needed.

---

## Mutation Workflow

Same principle — search first, then build:

```bash
# Find mutations
bash ${CLAUDE_SKILL_DIR}/scripts/search_mutations.sh "subscription"

# Describe the input type for a mutation's argument
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh CreateSubscriptionInput

# Execute
curl -s \
  -H "Content-Type: application/json" \
  -H "X-Gaiia-Api-Key: ${GAIIA_API_KEY}" \
  -d '{"query": "mutation { ... }"}' \
  https://api.gaiia.com/api/v1 | jq .
```

---

## Worked Example: "Find all subscriptions for customer X"

```bash
# 1. Cache schema
bash ${CLAUDE_SKILL_DIR}/scripts/introspect.sh

# 2. Find subscription-related types
bash ${CLAUDE_SKILL_DIR}/scripts/search_types.sh "subscription"
# → Show results to user, confirm which type to explore

# 3. Describe the Subscription type
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh Subscription
# → Note fields: id, status, customerId, items, ...

# 4. Find the query entry point
bash ${CLAUDE_SKILL_DIR}/scripts/describe_type.sh Query
# → Find field: subscriptions(customerId: ID!): [Subscription]

# 5. Execute
curl -s \
  -H "Content-Type: application/json" \
  -H "X-Gaiia-Api-Key: ${GAIIA_API_KEY}" \
  -d '{"query": "{ subscriptions(customerId: \"CUSTOMER_X_ID\") { id status items { id } } }"}' \
  https://api.gaiia.com/api/v1 | jq .
```

---

## Key Rules

- **Never guess field or type names.** Always verify with `describe_type.sh` first.
- **Show intermediate results to the user** at Step 2 so they can steer the exploration.
- **Use the cached schema** — avoid re-fetching on every step.
- **Load API key from env** — never hardcode it. See [references/setup.md](references/setup.md).
