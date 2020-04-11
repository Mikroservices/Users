#### Sign in to the system (via `authenticateToken`)

Endpoint for signing in user into the system. It requires `authenticateToken`. Returns two things:

- `accessToken` - JWT token with basic information about user, signed in by private key from settings.
- `refreshToken` - token which should be used for refreshing access token.

`Refresh token` has a much longer life time (~30 days) then `access token` (~1 hour). You should use `refresh token` for downloading new `access token`.

**Request**

```
METHOD: POST
URL: /identity/login
BODY:
{
    "authenticateToken": "aduiyfgv6vdvsdv76sdgfv7ds8gd6fv78dgfv8ds6fv8sdf"
}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "accessToken": "4Zo6SK6VFSxrRVN......3ZKcW35jRo43BQShJfBcpleQPY",
    "refreshToken": "himl3VsU0Uq3oFSIF2ihPwwX5NGdQ1TLOs99Ox3p6"
}
```

**Errors**

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "invalidAuthenticateToken",
    "reason": "Authenticate token is invalid."
}
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "authenticateTokenExpirationDateNotFound",
    "reason": "Authentication token don't have expiration date."
}
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "autheticateTokenExpired",
    "reason": "Authentication token expired."
}
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "userAccountIsBlocked",
    "reason": "User account is blocked. User cannot login to the system right now."
}
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "internalServerError",
    "reason": "Private key is not configured in database."
}
```
