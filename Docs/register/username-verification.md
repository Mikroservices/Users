#### Verify user name

Endpoint can be used to verification if user can use specified user name for his new account. It returns `true` if user name is valid and user can create user with that user name.

**Request**

```
METHOD: GET
URL: /register/username/@{username}
```
**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "result": true
}
```
