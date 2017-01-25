#!/bin/bash
set -e
set -x

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTDIR="${BASEDIR}/tests/integration"
cd "${TESTDIR}"

COMMIT=$(git log -n 1 --pretty=format:"%H")

rm -rf profanity-omemo-plugin
git clone ../../ profanity-omemo-plugin
git checkout $COMMIT

docker-compose stop
docker-compose rm -f

docker-compose build alice

#docker-compose run --rm alice file /home/profanity/.local/share/profanity/plugins/prof_omemo_plugin.py
rm -f tests/integration/profanity-conf/alice/logs/profanity.log
docker-compose run --rm alice alice@prosody 00-enable-omemo
cat tests/integration/profanity-conf/alice/logs/profanity.log
