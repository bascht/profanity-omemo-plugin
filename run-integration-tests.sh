#!/bin/bash
set -e


message () { printf "\n##\n# $1\n##\n\n"; }

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTDIR="${BASEDIR}/tests/integration"
ALICE_LOG=${TESTDIR}/profanity-conf/alice/logs/profanity.log
cd "${TESTDIR}"

COMMIT=$(git log -n 1 --pretty=format:"%H")

message "Preparing Build environment"
rm -rf profanity-omemo-plugin
git clone ../../ profanity-omemo-plugin
git checkout $COMMIT

message "Building Containers"
docker-compose stop
docker-compose rm -f
docker-compose build alice


message "Test: Plugin is installed"
rm -f $ALICE_LOG
docker-compose run --rm alice alice@prosody 00-enable-omemo
grep "Adding Disco Feature eu.siacs.conversations.axolotl.devicelist+notify" $ALICE_LOG
grep "ProfOmemoPlugin - Announce own device list" $ALICE_LOG
grep "Loaded plugin: prof_omemo_plugin.py" $ALICE_LOG
