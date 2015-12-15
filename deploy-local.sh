#!/bin/bash

## Edit these two lines according to your server setup

HOST="x@sx.com -pxxxx"
DEPLOY_DIR="/home/xxxx/deploy/"

## Probably don't edit any of the below unless you want to modify functionality

## Install?
ssh $HOST << EOF
	cd ~
	#Clone in deployment scripts if they don't already exist
	if [ ! -d "$DEPLOY_DIR" ]; then
		echo "Setting up remote deployment scripts in $DEPLOY_DIR"
		git clone "https://github.com/sheadawson/silverstripe-bash-deploy.git" $DEPLOY_DIR
		chmod +x "${DEPLOY_DIR}deploy.sh"
		chmod +x "${DEPLOY_DIR}configure.sh"
	fi
EOF

## Configure?
if [ "$1" == "configure" ]; then
	ssh $HOST -t "${DEPLOY_DIR}configure.sh; bash --login"
	exit
fi

## Deploy
if [ ! $1 ]; then
	ENVIRONMENT='prod'
else
	ENVIRONMENT=${1}
fi

CONFIG_FILE="${DEPLOY_DIR}config/config-${ENVIRONMENT}"

ssh $HOST << EOF
  cd $DEPLOY_DIR

  if [ ! -f "$CONFIG_FILE" ]; then
  	echo "No config file $CONFIG_FILE found. Please run configure"
  	exit
  fi

  ./deploy.sh $ENVIRONMENT
  exit
EOF
