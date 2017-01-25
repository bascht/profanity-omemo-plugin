#!/bin/bash
set -e

RED='\033[0;33m'
BROWN='\033[0;35m'
GREEN='\033[0;32m'
CLEAR='\033[0m'
message () { printf "\n${BROWN}##\n# $1\n##${CLEAR}\n\n"; }
success () { run "${1}"; return $?; }
failure () { run "${1}"; return $?; }
run () {
    method=${FUNCNAME[1]};
    out=$(eval $1);
    status=$?;
    
    if  [[ $status -eq 0 && $method = "success" ]] || [[ $status -ne 0 && $method = "failure" ]] ; then
        printf "${GREEN}PASS: ${out}${CLEAR}\n";
        retval=0;
    else
        printf "${RED}FAIL: ${out}${CLEAR}\n";
        retval=1;
    fi

    return $retval;
}

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTDIR="${BASEDIR}/tests/integration"
ALICE_LOG=${TESTDIR}/profanity-conf/alice/logs/profanity.log
cd "${TESTDIR}"

COMMIT=$(git log -n 1 --pretty=format:"%H")

message "Preparing Build environment"
rm -rf profanity-omemo-plugin
git clone ../../ profanity-omemo-plugin
git checkout $COMMIT

message "Cleaning up existing Profanity-Confs"
rm -rf ${TESTDIR}/profanity-conf/{alice,bob}/{accounts,chatlogs,logs,capscache,pgp,plugin_settings,plugin_themes,plugins,otr,omemo}
find ${TESTDIR}/profanity-conf

message "Building Containers"
docker-compose stop
docker-compose rm -f

docker-compose build

message "Test: Plugin is installed"
rm -f $ALICE_LOG

docker-compose run --rm alice alice@prosody 00-enable-omemo
success "grep 'Adding Disco Feature eu.siacs.conversations.axolotl.devicelist+notify' ${ALICE_LOG}"
success "grep 'ProfOmemoPlugin - Announce own device list' ${ALICE_LOG}"
success "grep 'Loaded plugin: prof_omemo_plugin.py' ${ALICE_LOG}"

docker-compose run --rm bob bob@prosody 00-enable-omemo


message "Test: Subscribe Alice to Bob and vice versa"
rm -f $ALICE_LOG
docker-compose run --rm alice alice@prosody 01-add-bob
success "grep 'Sent subscription request to bob@prosody' ${ALICE_LOG}"

docker-compose run --rm bob bob@prosody 01-add-alice
docker-compose run --rm bob bob@prosody 02-allow-alice
rm -f $ALICE_LOG

docker-compose run --rm alice alice@prosody 02-confirm-bob
success "grep 'Accepted subscription for bob@prosody' ${ALICE_LOG}"

message "Test: Start a Conversation and check for message content"
rm -f $ALICE_LOG
docker-compose run --rm alice alice@prosody 03-start-conversation
docker-compose run --rm bob bob@prosody 03-reply-to-alice

#success "grep 'Hey there, I am Alice' ${TESTDIR}/profanity-conf/bob/chatlogs/bob_at_prosody/alice_at_prosody/*"
success "grep 'Hey there, I am Alice' ${TESTDIR}/profanity-conf/alice/chatlogs/alice_at_prosody/bob_at_prosody/*"
#success "grep 'Hey, I am Bob' ${TESTDIR}/profanity-conf/alice/chatlogs/alice_at_prosody/bob_at_prosody/*"
#success "grep 'Hey, I am Bob' ${TESTDIR}/profanity-conf/bob/chatlogs/bob_at_prosody/alice_at_prosody/*"

message "Test: Checking for OMEMO Plugin errors"
failure "grep 'Plugin error' ${ALICE_LOG}"
