# Rate Limits

Gaiia uses a **leaky bucket** algorithm. Each request costs a number of points based on complexity and records returned. The bucket refills over time.

- **Bucket capacity**: 500 points (contact support to increase)
- **Cost factors**: number of records returned, query complexity

## Response headers

Every API response includes:

```
X-Rate-Limit-Allowed: true          # false = request was rejected
X-Rate-Limit-Cost: 138              # points this request cost
X-Rate-Limit-Limit: 500             # bucket capacity
X-Rate-Limit-Used: 462              # points consumed
X-Rate-Limit-Remaining: 38          # points left
X-Rate-Limit-Retry-At: 2024-06-27T19:01:02.000Z  # when to retry if rejected
```

## Best practices

- Use `first:` to limit page size — smaller pages cost fewer points
- Check `X-Rate-Limit-Remaining` before making batch requests
- On `RATE_LIMITED` error, wait until `retryAt` before retrying
- For bulk/analytics workloads, use Snowflake instead of the API

## Rate limit error

```json
{
  "errors": [{
    "message": "You have exceeded the allowed rate limit...",
    "extensions": {
      "code": "RATE_LIMITED",
      "retryAt": "2024-06-27T19:01:02.000Z"
    }
  }]
}
```

See [errors.md](errors.md) for full error response structure.
