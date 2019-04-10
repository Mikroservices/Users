#### Sign in to the system

Endpoint for signing in user into the system. It requires user name or email and password. Returns two things:

- `accessToken` - JWT token with basic information about user, signed in by private key from settings.
- `refreshToken` - token which should be used for refreshing access token.

`Refresh token` has a much longer life time (~30 days) then `access token` (~1 hour). You should use `refresh token` for downloading new `access token`.

**Request**

```
METHOD: POST
URL: /account/login
BODY:
{
    "userNameOrEmail": "johndoe@email.com",
    "password": "P@ssw0rd"
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
    "code": "invalidLoginCredentials",
    "reason": "Given user name or password are invalid."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "emailNotConfirmed",
    "reason": "User email is not confirmed. User have to confirm his email first."
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