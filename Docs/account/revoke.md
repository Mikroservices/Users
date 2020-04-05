#### Revoke refresh tokens

Endpoint for revoking all refresh tokens which belows to specific user.

**Request**

```
METHOD: POST
URL: /account/revoke/@{username}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

```
STATUS: 403 (Forbidden)
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
