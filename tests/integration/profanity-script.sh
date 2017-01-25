#!/bin/bash

echo "script.start=${2}" >> /home/profanity/.local/share/profanity/accounts

exec profanity -a ${1}
