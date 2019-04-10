#### Get user (profile)

Endpoint returns user data. It's public endpoint. Some data (like email and birth date) are visible only for the owner.

**Request**

```
METHOD: GET
URL: /users/@{username}
```

**Response**

```
STATUS: 200 (Ok)
BODY:
{
    "id": "19349a02-81c1-4506-b70a-c1b442e2fc1b"
    "email": "johndoe@email.com",
    "userName": "johndoe",
    "password": "P@ssw0rd",
    "bio": "This is some bio...",
    "location": "London",
    "website": "http://johndoe.io",
}
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