#### Refresh access token

Endpoint for refreshing access token.

**Request**

```
METHOD: POST
URL: /account/refresh
BODY:
{
    "refreshToken": "himl3VsU0Uq3oFSIF2ihPwwX5NGdQ1TLOs99Ox3p6"
}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "accessToken": "GUoSGcqNqsKP7cQd......tE8O5FQN1btqSjhbw5hxH9EBh",
    "refreshToken": "LPB4euZSHaODXJA1W650rvReKwnrBngjEAx2MxCvz"
}
```

**Errors**

```
STATUS: 404 (NotFound)
BODY: 
{
    "error": true,
    "code": "refreshTokenNotFound",
    "reason": "Refresh token not exists."
}
```

```
STATUS: 404 (NotFound)
BODY: 
{
    "error": true,
    "code": "userNotFound",
    "reason": "User not exists."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "refreshTokenRevoked",
    "reason": "Refresh token was revoked."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "refreshTokenExpired",
    "reason": "Refresh token was expired."
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