#### Create new user

Endpoint for creating new user in the system.

**Request**

```
METHOD: POST
URL: /register
BODY:
{
    "email": "johndoe@email.com",
    "userName": "johndoe",
    "password": "P@ssw0rd",
    "bio": "This is some bio...",
    "location": "London",
    "website": "http://johndoe.io",
    "securityToken": "a712udda8df822d8sa8w8dsac8sa7das8a990c"
}
```

**Response**

```
STATUS: 201 (Created)
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
    "code": "securityTokenIsInvalid",
    "reason": "Security token is invalid (Google reCaptcha API returned that information)."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "userNameIsAlreadyTaken",
    "reason": "User with provided user name already exists in the system."
}
```

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "emailIsAlreadyConnected",
    "reason": "Email is already connected with other account."
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