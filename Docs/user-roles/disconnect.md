#### Disconnect role from user

Endpoint for disconnecting user from role.

```
METHOD: POST
URL: /user-roles/disconnect
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
    "code": "roleNotFound",
    "reason": "Role not exists."
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