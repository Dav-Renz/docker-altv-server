#!/bin/bash


# starting directory
START_DIR=$(pwd)

# general alt:V server options
ALTV_SERVER_NAME:-"Alt:V Server on Docker!"
ALTV_SERVER_HOST:-"0.0.0.0"
ALTV_SERVER_PORT:-"7788"
ALTV_SERVER_PLAYERS:-"10"
ALTV_SERVER_PASSWORD:-""
ALTV_SERVER_ANNOUNCE:-"false"
ALTV_SERVER_TOKEN:-""
ALTV_SERVER_GAMEMODE:-"none"
ALTV_SERVER_WEBSITE:-""
ALTV_SERVER_LANGUAGE:-"en"
ALTV_SERVER_DESCRIPTION:-"A Alt:V server running in a Docker container."
ALTV_SERVER_MODULES:-"csharp-module,js-module"
ALTV_SERVER_RESOURCES:-""
ALTV_SERVER_LOG_PATH:-""
ALTV_SERVER_EXTRA_RES_PATH:-""
ALTV_SERVER_NO_LOGFILE:-"true"
ALTV_SERVER_JUSTPACK:-""
ALTV_SERVER_DEBUG:-"false"
ALTV_SERVER_EARLYAUTH_URL:-""

#alt:V auth options

ALTV_AUTH_DB_URL:-""mongodb://127.0.0.1:27017","
ALTV_AUTH_DB_DATABASE:-""altv","
ALTV_AUTH_DB_COLLECTIONS:-"["accounts"],"
ALTV_AUTH_DB_USERNAME:-"null,"
ALTV_AUTH_DB_PASSWORT:-"null"


# resources stuff

ALTV_RES_UPDATE_GAMEMODE:-"false"
ALTV_RES_UPDATE_AUTH:-"false"
ALTV_RES_UPDATE_OTHER_RES:-"false"

ALTV_RES_SCRIPT_URL:-""

# alt:V server CDN options
ALTV_SERVER_CDN_URL=${ALTV_SERVER_CDN_URL:-""}

if [ ! -z "$ALTV_SERVER_PASSWORD" ]; then
    ALTV_SERVER_PASSWORD="password: $ALTV_SERVER_PASSWORD"
fi

if [ ! -z "$ALTV_SERVER_TOKEN" ]; then
    ALTV_SERVER_TOKEN="token: $ALTV_SERVER_TOKEN"
fi

if [ ! -z "$ALTV_SERVER_WEBSITE" ]; then
    ALTV_SERVER_WEBSITE="website: $ALTV_SERVER_WEBSITE"
fi

if [ ! -z "$ALTV_SERVER_LOG_PATH" ]; then
    ALTV_SERVER_LOG_PATH="--logfile $ALTV_SERVER_LOG_PATH"
fi

if [ ! -z "$ALTV_SERVER_EXTRA_RES_PATH" ]; then
    ALTV_SERVER_EXTRA_RES_PATH="--extra-res-folder $ALTV_SERVER_EXTRA_RES_PATH"
fi

if [ "$ALTV_SERVER_NO_LOGFILE" = "true" ]; then
    ALTV_SERVER_NO_LOGFILE="--no-logfile"
else
    ALTV_SERVER_NO_LOGFILE=""
fi

if [ "$ALTV_SERVER_JUSTPACK" = "true" ]; then
    ALTV_SERVER_JUSTPACK="--justpack"
fi

if [ ! -z "$ALTV_SERVER_CDN_URL" ]; then
    ALTV_SERVER_CDN_URL="useCdn: true
cdnUrl: \"$ALTV_SERVER_CDN_URL\""
fi


if [ "$ALTV_RES_UPDATE_GAMEMODE" = "true" ]; then
    echo "Updating Gamemode"
    cd resources
    cd altV_freeroam
	git up
    cd .. && cd ..
fi

if [ "$ALTV_RES_UPDATE_AUTH" = "true" ]; then
    echo "Updating Auth Resource"
    cd /opt/altv/resources/altv-os-auth
	git up
    cd $START_DIR
    #cd resources
    #cd altv-os-auth
	#git up
    #cd .. && cd ..
fi

if [ "$ALTV_RES_UPDATE_OTHER_RES" = "true" ]; then
    echo "Updating other Resources"
    cd /opt/altv/resources/altv-server-resources
	git up
    cd $START_DIR
    cp -a /opt/altv/resources/altv-server-resources/* /opt/altv/resources/

	#wget -O update-res.zip "$ALTV_RES_SCRIPT_URL"
    #unzip -o update-res.zip
    #rm update-res.zip
    #chmod +x update-res.sh
    #/bin/bash update-res.sh
fi


cat <<EOF >/opt/altv/AltV.Net.Host.runtimeconfig.json
{
  "runtimeOptions": {
    "tfm": "net6",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "6.0.0"
    }
  }
}
EOF

cat <<EOF >/opt/altv/server.cfg
name: "$ALTV_SERVER_NAME"
host: "$ALTV_SERVER_HOST"
port: $ALTV_SERVER_PORT
debug: $ALTV_SERVER_DEBUG
players: $ALTV_SERVER_PLAYERS
announce: $ALTV_SERVER_ANNOUNCE
gamemode: "$ALTV_SERVER_GAMEMODE"
language: "$ALTV_SERVER_LANGUAGE"
description: "$ALTV_SERVER_DESCRIPTION"
modules: [ $ALTV_SERVER_MODULES ]
resources: [ $ALTV_SERVER_RESOURCES ]

$ALTV_SERVER_EARLYAUTH_URL

$voiceCfg

$ALTV_SERVER_PASSWORD
$ALTV_SERVER_TOKEN
$ALTV_SERVER_WEBSITE
$ALTV_SERVER_CDN_URL
EOF

cat <<EOF >/opt/altv/config.json
{
    "db_url": $ALTV_AUTH_DB_URL
    "db_database": $ALTV_AUTH_DB_DATABASE
    "db_collections": $ALTV_AUTH_DB_COLLECTIONS
    "db_username": $ALTV_AUTH_DB_USERNAME
    "db_password": $ALTV_AUTH_DB_PASSWORT
}
EOF

./altv-server --config=/opt/altv/server.cfg $ALTV_SERVER_LOG_PATH $ALTV_SERVER_NO_LOGFILE $ALTV_SERVER_EXTRA_RES_PATH ${@:1}
