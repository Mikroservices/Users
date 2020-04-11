#### Callback from OpenId Connect provider

Endpoint will be executed by OpenId Connect provider. In the URI we have to have correct client name and in the query string we will have  parameters: `code`, `state` and `scope`, created by OpenId Connect providers. After `code` verification page is redirected to the Web application (url specified in `callbackUrl` in 'AuthClient` table). In the url there is `authenticateToken` parameter which can be exchange for the `accessToken`.

**Request**

```
METHOD: GET
URL: /identity/callback/{uri}?code=23rfwd4eftg34frt45rt54g&state=8gwefgvuygfd7gvdfvdgfv7&scope=email%20profile

```
**Response**

```
STATUS: 302 (Redirect)
HEADERS:
    "Location": "https://yourapplication.com/login?authenticateToken=aduiyfgv6vdvsdv76sdgfv7ds8gd6fv78dgfv8ds6fv8sdf"
```

**Errors**

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "invalidClientName",
    "reason": "Client name have to be specified in the URL."
}
```

```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "clientNotFound",
    "reason": "Client with given name was not found."
}
```


```
STATUS: 400 (BadRequest)
BODY:
{
    "error": true,
    "code": "codeTokenNotFound",
    "reason": "Code token was not found."
}
```
