#!/bin/bash

mkdir -p /home/profanity/.config/profanity
cat > /home/profanity/.config/profanity/profrc <<EOF
[ui]
history=true
[logging]
chlog=true
EOF

cat > /home/profanity/.local/share/profanity/accounts <<EOF
[${1}]
enabled=true
jid=${1}
resource=profanity
password=${1}
muc.service=prosody
muc.nick=alice
presence.last=online
presence.login=online
priority.online=0
priority.chat=0
priority.away=0
priority.xa=0
priority.dnd=0
server=prosody
tls.policy=disable
script.start=${2}
EOF
#/bin/bash
exec profanity -a ${1}
