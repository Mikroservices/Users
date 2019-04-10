#### Delete user account

Endpoint for deleting user account.

```
METHOD: DELETE
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
URL: /users/@{username}
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
BODY: 
{
    "error": true,
    "code": "userForbidden",
    "reason": "Access to specified user is forbidden."
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