#### Change password

Endpoint for change user password.

**Request**

```
METHOD: POST
URL: /account/change-password
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
BODY:
{
    "currentPassword": "P@ssw0rd",
    "newPassword": "NewP@ssw0rd"
}
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
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "invalidLoginCredentials",
    "reason": "Given user name or password are invalid."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "emailNotConfirmed",
    "reason": "User email is not confirmed. User have to confirm his email first."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "userAccountIsBlocked",
    "reason": "User account is blocked. User cannot login to the system right now."
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
