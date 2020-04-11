#### Redirect to OpenId Connect provider

Endpoint should be used for redirect to the OpenId Connect provider. Web application should open that endpoint in the browser. That endpoint based on URI will return `302` response and redirect to proper sign in page.

**Request**

```
METHOD: GET
URL: /identity/authenticate/{uri}

```
**Response**

```
STATUS: 302 (Redirect)
HEADERS:
    "Location": "https://accounts.google.com/o/oauth2/v2/auth"
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
