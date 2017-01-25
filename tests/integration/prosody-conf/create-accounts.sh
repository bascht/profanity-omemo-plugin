#!/bin/bash


prosodyctl register alice prosody alicepass
prosodyctl register bob prosody bobpass

exec prosodyctl start
