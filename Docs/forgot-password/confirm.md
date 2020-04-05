#### Change password

Endpoint is responsible for setting up new password. It requires GUID generated in previous endpoint and new password.

**Request**

```
METHOD: POST
URL: /forgot/confirm
BODY:
{
    "forgotPasswordGuid": "9957D516-761A-4D86-B281-E31F2D707F3B",
    "password": "P@ssw0rd"
}
```

**Response**

```
STATUS: 200 (Ok)
```

**Errors**

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
    "code": "userAccountIsBlocked",
    "reason": "User account is blocked. You cannot change password right now."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "tokenExpired",
    "reason": "Token which allows to change password expired. User have to repeat forgot password process."
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
