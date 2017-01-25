#!/bin/bash


prosodyctl register alice prosody alice@prosody
prosodyctl register bob prosody bob@prosody

exec prosodyctl start
