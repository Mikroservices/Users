#### Update user data

Endpoint for updating user data.

```
METHOD: PUT
URL: /users/@{username}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
BODY:
{
    "id": "19349a02-81c1-4506-b70a-c1b442e2fc1b",
    "email": "johndoe@email.com",
    "userName": "johndoe",
    "bio": "This is some bio...",
    "location": "London",
    "website": "http://johndoe.io"
}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "id": "19349a02-81c1-4506-b70a-c1b442e2fc1b"
    "email": "johndoe@email.com",
    "userName": "johndoe",
    "bio": "This is some bio...",
    "location": "London",
    "website": "http://johndoe.io",
}
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

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "securityTokenIsMandatory",
    "reason": "Security token is mandatory (it should be provided from Google reCaptcha)."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "validationError",
    "reason": "[different validation messages for each field]"
}
```