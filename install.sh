#!/usr/bin/env bash
set -e

set -e
set -v
set -x

python setup.py install --force --user
mkdir -p ~/.local/share/profanity/plugins
cp deploy/prof_omemo_plugin.py ~/.local/share/profanity/plugins/
