#### Create new authentication client

Endpoint for creating new authentication client.

```
METHOD: POST
URL: /auth-client
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
BODY:
{
    "uri": "microsoft",
    "callbackUrl": "http://localhost:4200/login-callback",
    "tenantId": "432523-3432-43cf-9da5-f75728b8d21f",
    "clientId": "731f2cab-2658-4c3e-9340-9461e3c6388c",
    "type": "microsoft",
    "clientSecret": "123123",
    "name": "Microsoft",
    "svgIcon": "<svg></svg>"
}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "uri": "microsoft",
    "id": "51BA689F-1787-49EA-8311-23EFAD6C1852",
    "callbackUrl": "http://localhost:4200/login-callback",
    "tenantId": "432523-3432-43cf-9da5-f75728b8d21f",
    "clientId": "731f2cab-2658-4c3e-9340-9461e3c6388c",
    "type": "microsoft",
    "clientSecret": "",
    "name": "Microsoft",
    "svgIcon": "<svg></svg>"
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
