# :couple: Mikroservices - Users

![Build Status](https://github.com/Mikroservices/Users/workflows/Build/badge.svg)
[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 4](https://img.shields.io/badge/vapor-4.0-blue.svg?style=flat)](https://vapor.codes)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)


Microservice which provides common features for managing users (only RESTful API).
Application is written in [Swift](https://swift.org) and [Vapor 4](https://vapor.codes) and operates on PostgreSQL or SQLite databases.
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
- [`POST /account/revoke/@{username}`](Docs/account/revoke.md) - revoke all refresh tokens for user

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

First you need to have [Swift](https://swift.org) installed on your computer.
Next you should run following commands:

```bash
$ git clone https://github.com/Mikroservices/Users.git
$ cd Users
$ swift package update
$ swift build
```

Now you can run the application:

```bash
$ .build/debug/Run serve --port 8000
```

If application starts open following link in your browser: [http://localhost:8001](http://localhost:8001).
You should see blank page with text: *Service is up and running!*. Now you can use API which is described above.

## Database

If you want to use persistent database you have to add system environment `MIKROSERVICE_USERS_CONNECTION_STRING` with connection string to the database.

**Connection string for PostgreSQL:** 

```
Variable name:              MIKROSERVICE_USERS_CONNECTION_STRING
Value (connection string):  postgresql://user:password@host:5432/database?sslmode=require
```

**Connection string for SQLite:** 

```
Variable name:              MIKROSERVICE_USERS_CONNECTION_STRING
Value (connection string):  users.db
```

You can set up this variable as:

1. environment variable in your system
2. environment variable in XCode


## Configuration

The application uses predefined settings. All settings are stored in the database in the `Setting` table.
We can find there following settings:

- `isRecaptchaEnabled` - information about enable/disable Google Recaptcha, it's highly recommended to enable this feature. Recaptcha is validated during user registration process.
- `recaptchaKey` - secret key for Google Recaptcha.
- `jwtPrivateKey` - RSA512 key for generating JWT tokens (signing in). Private key should be entered only in that service. Other services should use only public key.
- `emailServiceAddress` - address to service responsible for sending emails (confirmation email, forgot your password features).
- `corsOrigin` - CORS origin address. Example value: `http://origina.com/, http://originb.com/` (if empty all origins are accepted). 
- `eventsToStore` - list of events which should be stored in events table. Possible values are (separated by comma):
  - `accountLogin` - logins to the system,
  - `accountRefresh` - refreshing access tokens,
  - `accountChangePassword` - changing password,
  - `accountRevoke` - revoking access tokens,
  - `forgotToken` - forgot password,
  - `forgotConfirm` - confirming changing password,
  - `registerNewUser` - registering new user,
  - `registerConfirm` - confirm new user registrations,
  - `registerUserName` - user name verifying,
  - `registerEmail` - email veryifying,
  - `rolesCreate` - role creating,
  - `rolesList` - list of roles,
  - `rolesRead` - role details,
  - `rolesUpdate` - role updating,
  - `rolesDelete` - role deleting,
  - `userRolesConnect` - connecting user to role,
  - `userRolesDisconnect` - disconnecting role from user,
  - `usersRead` - user details,
  - `usersUpdate` - user updating,
  - `usersDelete` - user deleting.

In production environment you *MUST* change especially `jwtPrivateKey`.

Also during registration process and forgot password process service will try send emails to the user. That's why correct address to email service must be defined. For that purposes you can use for example: [SendGridEmails](https://github.com/Mikroservices/SendGridEmails) service.
