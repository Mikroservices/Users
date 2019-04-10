#### Forgot password

Endpoint is sending email with link to your website. Link in query parameter contains special GUID which have to used in next endpoint.

**Request**

```
METHOD: POST
URL: /forgot/token
BODY:
{
    "email": "johndoe@email.com"
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