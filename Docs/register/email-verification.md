#### Verify email

Endpoint can be used to verification if user can use specified email for his new account. It returns `true` if email is valid and user can create user with that email.

**Request**

```
METHOD: GET
URL: /register/email/{email}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "result": true
}
```