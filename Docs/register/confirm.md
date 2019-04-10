#### Confirm user account

Endpoint should be used for email verification. During creating account special email is sending. In that email there is a link to your website (with `id` and `confirmationGuid` as query parameters). You have to create page which will read that parameters and it should send request to following endpoint. Only after that procedure user can sign-in to the system.

**Request**

```
METHOD: POST
URL: /register/confirm
BODY:
{
    "id": "19349a02-81c1-4506-b70a-c1b442e2fc1b",
    "confirmationGuid": "1bb5118c-6814-4991-8410-de6656b19a2c"
}
```
**Response**

```
STATUS: 200 (Ok)
```

**Errors**

```
STATUS: 400 (BadRequest)
BODY: 
{
    "error": true,
    "code": "invalidIdOrToken",
    "reason": "Invalid user Id or token. User have to activate account by reseting his password."
}
```