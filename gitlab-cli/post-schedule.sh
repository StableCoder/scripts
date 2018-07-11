#!/bin/sh

TOKEN=
NAME=
REFERENCE=
CRON=
TIMEZONE=UTC
ACTIVE=true
SERVER=
PROJECT_ID=

printf "\nPrivate token:\n"
read TOKEN
printf "Schedule name:\n"
read NAME
printf "Branch or tag reference name:\n"
read REFERENCE
printf "CRON:\n"
read CRON
printf "GitLab server:\n"
read SERVER
printf "Project ID:\n"
read PROJECT_ID

curl --request POST --header "PRIVATE-TOKEN: $TOKEN" --form description="$NAME" --form ref="$REFERENCE" --form cron="$CRON" --form cron_timezone="$TIMEZONE" --form active="$ACTIVE" "${SERVER}/api/v4/projects/${PROJECT_ID}/pipeline_schedules"
printf "\n"