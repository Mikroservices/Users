# :couple: Mikroservices - Users

[![Build Status](https://travis-ci.org/Mikroservices/Users.svg?branch=master)](https://travis-ci.org/Mikroservices/Users) [![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](ttps://developer.apple.com/swift/) [![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

Microservice which provides common features for managing users (only RESTful API).
Application is written in [Swift](https://swift.org) and [Vapor 3](https://vapor.codes) and operates on PostgreSQL database.
All functionalities are constantly verified by unit tests.

## Main features

Main features which has been implemented:

- registering new user
- sign-in user (JWT access token & refresh token)
- forgot password
- change password
- update user data
- user roles

*Class diagram*

![model](Images/model.png)

## API

Service provides simple RESTful API. Below there is a description of each endpoint.

Creating new user:

- [`POST /register`](Docs/register/create.md) - register new user
- [`POST /register/confirm`](Docs/register/confirm.md) - confirming user account
- [`GET /register/username/@{username}`](Docs/register/username-verification.md) - user name verification
- [`GET /register/email/{email}`](Docs/register/email-verification.md) - email verification

User account management:

- [`POST /account/login`](Docs/account/login.md) - login user into system (returns JWT access token)
- [`POST /account/refresh`](Docs/account/refresh.md) - refresh JWT access token
- [`POST /account/change-password`](Docs/account/change-password.md) - change user password

Forgot password actions:

- [`POST /forgot/token`](Docs/forgot-password/token.md) - generate token for restoring password
- [`POST /forgot/confirm`](Docs/forgot-password/confirm.md) - new password

User data management:

- [`GET /users/@{username}`](Docs/users/profile.md) - get user profile
- [`PUT /users/@{username}`](Docs/users/update.md) - update user data
- [`DELETE /users/@{username}`](Docs/users/delete.md) - deleting user account

Role management:

- [`GET /roles`](Docs/roles/list.md) - list of roles
- [`GET /roles/{id}`](Docs/roles/role.md) - specific role
- [`POST /roles`](Docs/roles/create.md) - new role
- [`PUT /roles/{id}`](Docs/roles/update.md) - update role data
- [`DELETE /roles/{id}`](Docs/roles/delete.md) - delete role

Connect user to role:

- [`POST /user-roles/connect`](Docs/user-roles/connect.md) - connect role to user
- [`POST /user-roles/disconnect`](Docs/user-roles/disconnect.md) - disconnect user from role

## Getting started

First you need to have [Swift](https://swift.org) installed on your computer and you have to create new database in PostgreSQL server.
Next you should run following commands:

```bash
$ git clone https://github.com/Mikroservices/Users.git
$ cd Users
$ swift package update
$ swift build
```

If application successfully builds you need to set up connection string to the database. 
Service supports only PostgreSQL database. 

```
Variable name:              MIKROSERVICE_USERS_CONNECTION_STRING
Value (connection string):  postgresql://user:password@host:5432/database?sslmode=require
```

You can set up this variable as:

1. environment variable in your system
2. environment variable in XCode

Now you can run the application:

```bash
$ .build/debug/Run --port 8001
```

If application starts open following link in your browser: [http://localhost:8001](http://localhost:8001).
You should see blank page with text: *Service is up and running!*. Now you can use API which is described above.

## Configuration

The application uses predefined settings. All settings are stored in the database in the `Setting` table.
We can find there following settings:

- `isRecaptchaEnabled` - information about enable/disable Google Recaptcha, it's highly recommended to enable this feature. Recaptcha is validated during user registration process.
- `recaptchaKey` - secret key for Google Recaptcha.
- `jwtPrivateKey` - RSA512 key for generating JWT tokens (signing in). Private key should be entered only in that service. Other services should use only public key.
- `emailServiceAddress` - address to service responsible for sending emails (confirmation email, forgot your password features).

In production environment you *MUST* change especially `jwtPrivateKey`.

Also during registration process and forgot password process service will try send emails to the user. That's why correct address to email service must be defined. For that purposes you can use for example: [SendGridEmails](https://github.com/Mikroservices/SendGridEmails) service.