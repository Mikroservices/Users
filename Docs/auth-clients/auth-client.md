#### Get specific authentication client

Endpoint for downloading specific authentication client data.

```
METHOD: GET
URL: /auth-clients/{id}
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
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "incorrectAuthClientId",
    "reason": "Authentication client id is incorrect."
}
```

```
STATUS: 404 (NotFound)
BODY:
{
    "error": true,
    "code": "authClientNotFound",
    "reason": "Authentication client not exists."
}
```

