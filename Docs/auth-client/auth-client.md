#### Get specific role

Endpoint for downloading specific role data.

```
METHOD: GET
URL: /roles/{id}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "id": "jt7390gt-63kt-09fw-b70a-c1b442e2fc1b",
    "name": "Administrator",
    "code": "administrator",
    "description": "This is role for people with high privileges.",
    "hasSuperPrivileges": true,
    "isDefault": false
}
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

```
STATUS: 403 (Forbidden)
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "incorrectRoleId",
    "reason": "Role id is incorrect."
}
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

