# Small(-ish) Prosody + Profanity Test setup

This got out of handy quickly. This setup will run two Profanity
Containers with `alice@prosody` and `bob@prosody` connecting to a
Prosody instance.

JIDs and Passwords are set on creation.

### Getting started

Run it (preferrably in two different tmux splits) with:

``` sh
docker-compose run alice
docker-compose run bob
```
