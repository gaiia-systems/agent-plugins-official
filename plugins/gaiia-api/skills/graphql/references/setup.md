# Gaiia API — Setup

## API Key

All requests require an `X-Gaiia-Api-Key` header. The scripts read the key from the `GAIIA_API_KEY` environment variable.

### Option A: .env file (recommended for project-local use)

Create a `.env` file in your working directory:

```
GAIIA_API_KEY=your_api_key_here
```

The scripts source this automatically. Add `.env` to your `.gitignore` to avoid committing secrets.

### Option B: Shell environment

Export the variable in your shell session or profile:

```bash
export GAIIA_API_KEY=your_api_key_here
```

## Verifying the setup

```bash
bash skills/gaiia-api/scripts/introspect.sh
```

A successful run saves `.gaiia-schema.json` in the current directory. An authentication error returns a JSON error body — double-check the key value.

## Getting an API key

API keys are managed in the Gaiia platform. Ask your account administrator if you don't have one.
