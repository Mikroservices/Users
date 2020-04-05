#### Update existing role

Endpoint for updating role.

```
METHOD: PUT
URL: /roles/{id}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
BODY:
{
    "id": "85kfh37i-kf82-dd92-032d-c1b442e2fc1b",
    "name": "Senior Developer",
    "code": "senior-developer",
    "description": "Some guy who creates code.",
    "hasSuperPrivileges": true,
    "isDefault": false
}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "id": "85kfh37i-kf82-dd92-032d-c1b442e2fc1b",
    "name": "Developer",
    "code": "developer",
    "description": "Some guy who creates code.",
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
    "code": "roleWithCodeExists",
    "reason": "Role with specified code already exists."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "validationError",
    "reason": "Validation errors occurs.",
    "failures": [
        {
            "field": "[FIELD]",
            "failure": "[VALIDATION MESSAGE]"
        }
    ]
}
```
