# Pagination

All collection fields use cursor-based pagination following the [Relay spec](https://relay.dev/graphql/connections.htm).

## Arguments

| Argument | Direction | Description |
|---|---|---|
| `first` | forward | Number of items to return (default: 50, max: **250**) |
| `after` | forward | Cursor to start after |
| `last` | backward | Number of items to return (default: 50, max: **250**) |
| `before` | backward | Cursor to start before |

Some fields have custom limits — check the field's description in the schema.

For bulk operations, backups, or analytics, query Snowflake instead of the API.

## Response structure

Every paginated field returns a `Connection` object:

```graphql
type AccountConnection {
  edges: [AccountEdge!]!   # each has cursor + node
  nodes: [Account!]!       # the actual objects (shorthand, no cursor)
  pageInfo: PageInfo!
  totalCount: Int!          # total across ALL pages, not just current
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

## Example: paginating through products

First page:

```graphql
query {
  products(first: 1) {
    nodes { name }
    pageInfo { endCursor hasNextPage }
    totalCount
  }
}
```

Next page (pass `endCursor` as `after`):

```graphql
query {
  products(first: 1, after: "YXJyYXljb25uZWN0aW9uOjA=") {
    nodes { name }
    pageInfo { endCursor hasNextPage }
  }
}
```

## Iterating all pages

Repeat with `after: <endCursor>` until `hasNextPage` is `false`.
