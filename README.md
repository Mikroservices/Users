# :couple: Letterer - Users

Microservice for management users in Letterer system.

## Developer environement

You can work on the microservice on macOS and Linux platforms. Below there are instructions for both.

### XCode (macos)

For developing application in XCode you need to do following steps:

1. Clone repository

Download source code by executing command:

```bash
$ git clone https://github.com/Letterer/Users.git
```

2. Open XCode

XCode is recommended IDE for developing service on macOS.

```
$ cd Users\
$ open Users.xcodeproj
```

3. Build & Run

Select the run scheme from the scheme menu and `My Mac` as the deployment target, then click the play button.

4. Verify

Open the url: `http://localhost:10001`.

### Command line (macos/Linux)

For developing application in XCode you need to do following steps:

1. Clone repository

Download source code by executing command:

```bash
$ git clone https://github.com/Letterer/Users.git
```

2. Add environment variables

You have to add new variables to you environment settings (e.g. to `.bashrc` or `.bash_profile` file). 

**RSA private key**

This is a variable which is mandatory for generating JWT tokens. Only this service is responsible for generating this token and only he should use that key. Below key is only for developer purposes. On production/test environment we should use other (private) key.

Name: `LETTERER_PRIVATE_KEY`

Value:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAh4WjL2kJmM2GwSp1h/SMyrx7hD99Hl5vdNqlEhJ7mpg7UHzn
K0A3nroOqo4Z8idkfM0kjTLFqlHdo1HU5jBmibfuTo8CpAwqKi6Ff+sR9mJd8QkQ
nPRmHgRg5hvbt8h1zHZokiKFUG0P5bCoZ/bgzHEXIVYZ3Y+htcvZwSIpZBqjZ/Qm
HjIk9Q7gKlcVUOgBuagerpvxELD4viOu7OETV3bpVa5boL55jJoxHmpUKiPaytOi
x8eRvi8YjUNf3uQ5y9ye+891BEsVxcjLDyHMUKcpj5e1EysLDLJJQsbRUElO0CCs
quATzcGbPz3pmF/5Wn1mRr+GoLD72Hr4wR9/MwIDAQABAoIBAHAY4Sc5KeADuQAU
n80KQl770utMHLE/CdBNfpbZRPZWD1H/TrOe1aLsYW9ARUPgw6Tbhu1oXsoIF12d
NY4F4PrvciX28wdArKvheTma9munZ+8VQXGiUslnc8NCrdZx8MZj9xFRjpY88BZc
rp/4PG++55QChTiYMvmOGZtAJ56NltJ8mDH/HPmHqrRqHTRy1Vvrm/zAxfZo8C9u
IFuGa6v2/apMhq5joRNcCrlLPUr6hJbaFIBzfKUUyF/7p8tx1YgSCxanjWTEh0gw
9dwx4Qr8aKIhleTB9fEHF0dtEJMfQDnnPZCCPKyZqPBAsprodglXFsTJFVrp6whh
V+24iHkCgYEA11sJ0OZTLTu2SAFL2PhmruQC8p0FPNkFJSsV6PMU+7cGAtgpVNN5
LeudTIpvBjSXtSpz6VugRxhiLWlXH1+9a//KT1DqIsJKtZjh/gscFQ7orLtseX2v
0EYB+80gL9aQtufZgKCz6TjHO1+SS7m4zInVijpqoGhQuNjuv1QQTtUCgYEAoRlr
IU+UvEPhl4gnt/yRbZalz2N/CBeezJG8GW7K5ru1yeYuxCKeSIfuDynkRmgsBfXp
2GFkG2WQQZ6CJ0YGk/KK77L32h8fKUOQQu9UaOvV7BoEjj++6JwsFOQ3X88JtGu8
KgPV/qPj1hxFT1ZIOu5y+haeLCB5bsTzHHVHaecCgYBV1zD7dsOS1SlcXD/qdWEg
tzxBjrtGvM6jOSBboYEssJCR063t5Pl5h2BE4S1OEOqjyQ845k/l5t9DcKjMlbIA
eY4fvYYGYuG6rvzt8Wm5Lx8psu+TIblR0IX745C/4MwATDxTXDs6bGplzTuYOahi
x1I57f0QgWQjujy4QP7bHQKBgDqpPtFKYSaMsUC0W4Irfekhyg7SdBdGQpTLHGtG
ZKvP/koefzj8Qha3KIBtCKp6lE03VodsLz+qo/TA+zPB0/NbhivyRz4txvMHnyhA
bcQm3Ca08qO5opKhC4wv7dn9UdNYx5OlAe9PTk9QzAwvpu2Oll9qjP4UdSNYpA3g
xrhRAoGAJjk4/TcoOMzSjaiMF3yq82CRblUvpo0cWLN/nLWkwJkhCgzf/fm7Z3Fs
2GosCdIK/krdgKYUThj02OmSB58oYCNn6W56G07yzDVeTIp0BrlsPuCMqGILabKP
4SlNoO/RqfjpSZRMnEpYPbrxgYkjC9nPB+Zy6mRCN7cYqJoqjng=
-----END RSA PRIVATE KEY-----
```

**Path to the database**

Variable stores path to the sqlite database file. You should put here proper path on you drive.

Name: `LETTERER_SQLITE_PATH`

Value: `/home/[USER]/Projects/Letterer/Databases/Users.db`

**Private key to Google reCaptcha**

Variable for secret key generated for the domain in Google: [https://www.google.com/recaptcha/admin](https://www.google.com/recaptcha/admin).

Name: `LETTERER_RECAPTCHA_KEY`

Value: ``

3. Build & Run

If you have Vapor installed on your Linux distribution you can run following commands:

```bash
$ cd Users/
$ vapor build
$ vapor run
```

Also you can build and run application by executing common swift commands.

```bash
$ cd Users/
$ swift package update
$ swift build
$ swift run
```

4. Verify

Open the url: `http://localhost:10001`.

## API

That microservice is mainly responsible for register and login user to the system. API which provides is described below.

### New user

Creates new user in the system. After creating an account user still cannot login. First he/she need to confirm email.

Url: `\users`

Method: `POST`


### Login

Login user to the system.

Url: `\users\login`

Method: `POST`

### Confirm email

Email confirmation.

Url: `\users\confirm`

Method: `POST`

