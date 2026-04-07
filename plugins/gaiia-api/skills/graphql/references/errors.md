# Errors

## HTTP status codes

GraphQL behaves differently from REST: many errors that would be `4xx`/`5xx` in REST instead return **HTTP 200** with an error payload.

## Mutation errors (in `data`)

Mutations return validation and business logic errors **inside the response data**, under an `errors` field on the mutation result — not in the top-level `errors` array.

```graphql
mutation CreateTicket {
  createTicket(...) {
    ticket { id }
    errors {
      code
      message
    }
  }
}
```

```json
{
  "data": {
    "createTicket": {
      "ticket": null,
      "errors": [{ "code": "TITLE_TOO_LONG", "message": "The title is too long." }]
    }
  }
}
```

Always request the `errors` field on mutations and check it before assuming success.

## Other errors (top-level `errors`)

System-level errors (auth failures, rate limits, unexpected errors) appear in the top-level GraphQL `errors` array with a `message` and `extensions` field:

```json
{
  "errors": [{
    "message": "You have exceeded the allowed rate limit...",
    "extensions": {
      "code": "RATE_LIMITED",
      "cost": 138,
      "limit": 500,
      "used": 462,
      "remaining": 38,
      "retryAt": "2024-06-27T19:01:02.000Z"
    }
  }]
}
```

Notable `extensions.code` values: `RATE_LIMITED`, `UNAUTHORIZED`, `FORBIDDEN`.
