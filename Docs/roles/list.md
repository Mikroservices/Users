#### Get roles

Endpoint for downloading user roles.

```
METHOD: GET
URL: /roles
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
BODY:
[
    {
        "id": "jt7390gt-63kt-09fw-b70a-c1b442e2fc1b",
        "name": "Administrator",
        "code": "administrator",
        "description": "This is role for people with high privileges.",
        "hasSuperPrivileges": true,
        "isDefault": false
    },
    {
        "id": "ut85jdnw-93jf-02js-jg92-c1b442e2fc1b",
        "name": "Member",
        "code": "member",
        "description": "Normal user",
        "hasSuperPrivileges": false,
        "isDefault": true
    }
]
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

```
STATUS: 403 (Forbidden)
```