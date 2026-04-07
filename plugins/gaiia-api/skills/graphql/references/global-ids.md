# Global IDs

All object IDs in the Gaiia API are **Global IDs** — not plain UUIDs.

## Format

```
account_pwE84wz4Mw15LPX5YE8Z3o
│       │
│       └── Base-58 encoded UUID (22 chars, Flickr alphabet)
└────────── snake_case type prefix
```

Examples:
- `account_pwE84wz4Mw15LPX5YE8Z3o` → an `Account`
- `product_8rnXNuR5sKP5uNwoPL41Zp` → a `Product`
- `inventory_item_...` → an `InventoryItem`

UUIDs (the raw form) appear in Snowflake, gaiia's global search, and some UI screens. When passing IDs in API queries or mutations, always use the Global ID format.

## Convert UUID → Global ID

**Algorithm**: strip UUID dashes → parse as hex → encode as Base-58 (Flickr alphabet) → left-pad to 22 chars → prepend `snake_case_type_`.

**Flickr Base-58 alphabet**: `123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ`

### JavaScript

```javascript
function generateGlobalId(typeName, uuidStr) {
  const ALPHABET = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
  const BASE = BigInt(ALPHABET.length);
  const TARGET_LEN = 22;

  const stripped = uuidStr.replace(/-/g, '').toLowerCase();
  let num = BigInt('0x' + stripped);

  const chars = [];
  while (num > 0n) {
    const rem = num % BASE;
    chars.unshift(ALPHABET[Number(rem)]);
    num = num / BASE;
  }
  while (chars.length < TARGET_LEN) chars.unshift(ALPHABET[0]);

  const snake = typeName.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase();
  return `${snake}_${chars.join('')}`;
}

// generateGlobalId('Account', '3c3b1978-6a68-4a13-bdc2-2d51c8ef7519')
// => "account_8rnXNuR5sKP5uNwoPL41Zp"
```

### Python

```python
import re

ALPHABET = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
BASE = len(ALPHABET)
TARGET_LEN = 22

def generate_global_id(type_name: str, uuid_str: str) -> str:
    stripped = uuid_str.replace('-', '').lower()
    num = int(stripped, 16)

    chars = []
    while num > 0:
        num, rem = divmod(num, BASE)
        chars.insert(0, ALPHABET[rem])
    while len(chars) < TARGET_LEN:
        chars.insert(0, ALPHABET[0])

    snake = re.sub(r'(?<!^)(?=[A-Z])', '_', type_name).lower()
    return f"{snake}_{''.join(chars)}"

# generate_global_id('Account', '3c3b1978-6a68-4a13-bdc2-2d51c8ef7519')
# => "account_8rnXNuR5sKP5uNwoPL41Zp"
```

## Convert Global ID → UUID

**Algorithm**: split off the short part after the last `_` segment (i.e., the 22-char Base-58 part) → decode Base-58 → to 32-char hex → insert UUID dashes.

### JavaScript

```javascript
function decodeGlobalId(globalId) {
  const ALPHABET = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
  const BASE = BigInt(ALPHABET.length);

  const [, shortId] = globalId.split('_', 2);

  let num = 0n;
  for (const ch of shortId) {
    num = num * BASE + BigInt(ALPHABET.indexOf(ch));
  }

  const hex = num.toString(16).padStart(32, '0');
  return `${hex.slice(0,8)}-${hex.slice(8,12)}-${hex.slice(12,16)}-${hex.slice(16,20)}-${hex.slice(20)}`;
}

// decodeGlobalId('account_8rnXNuR5sKP5uNwoPL41Zp')
// => "3c3b1978-6a68-4a13-bdc2-2d51c8ef7519"
```

### Python

```python
def decode_global_id(global_id: str) -> str:
    ALPHABET = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
    BASE = len(ALPHABET)

    _, short_id = global_id.split('_', 1)

    num = 0
    for ch in short_id:
        num = num * BASE + ALPHABET.index(ch)

    hex_str = format(num, 'x').rjust(32, '0')
    return f"{hex_str[0:8]}-{hex_str[8:12]}-{hex_str[12:16]}-{hex_str[16:20]}-{hex_str[20:]}"

# decode_global_id('account_8rnXNuR5sKP5uNwoPL41Zp')
# => "3c3b1978-6a68-4a13-bdc2-2d51c8ef7519"
```
