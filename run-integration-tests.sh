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
#docker-compose stop
#docker-compose rm -f
docker-compose build

message "Test: Plugin is installed"
rm -f $ALICE_LOG

docker-compose run --rm alice alice@prosody 00-enable-omemo
grep "Adding Disco Feature eu.siacs.conversations.axolotl.devicelist+notify" $ALICE_LOG
grep "ProfOmemoPlugin - Announce own device list" $ALICE_LOG
grep "Loaded plugin: prof_omemo_plugin.py" $ALICE_LOG

docker-compose run --rm bob bob@prosody 00-enable-omemo


message "Test: Subscribe Alice to Bob and vice versa"
rm -f $ALICE_LOG
docker-compose run --rm alice alice@prosody 01-add-bob
grep "Sent subscription request to bob@prosody" $ALICE_LOG

docker-compose run --rm bob bob@prosody 01-add-alice
docker-compose run --rm bob bob@prosody 02-allow-alice
rm -f $ALICE_LOG

docker-compose run --rm alice alice@prosody 02-confirm-bob
grep "Accepted subscription for bob@prosody" $ALICE_LOG

message "Test: Start a Conversation"
rm -f $ALICE_LOG
docker-compose run --rm alice alice@prosody 03-start-conversation

message "Test: Checking for message content"
grep "Hey there" ${TESTDIR}/profanity-conf/bob/chatlogs/bob_at_prosody/alice_at_prosody/*
grep "Hey there" ${TESTDIR}/profanity-conf/alice/chatlogs/alice_at_prosody/bob_at_prosody/*

message "Test: Checking for OMEMO Plugin errors"
grep "Plugin error" $ALICE_LOG
