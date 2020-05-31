#### Delete authentication client

Endpoint for deleting authentication client.

```
METHOD: DELETE
URL: /auth-client/{id}
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
    "code": "authClientNotFound",
    "reason": "Authentication client not exists."
}
```
