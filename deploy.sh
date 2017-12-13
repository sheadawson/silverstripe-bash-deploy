#!/bin/bash

set -e

# Gimme some color!

NC="\033[0m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"

# Settings
# PROJECT_DIR="/home/livesour/public_html/livesource.co.nz/"
# REPO="git@gitlab.com:livesource/livesource.git"
# BRANCH="master"
# PHP_EXEC="php"
# COMPOSER_EXEC="php composer.phar"

# check for valid request

if [ ! $# -eq 1 ]; then
	printf "\n${RED}Error: please provide config argument eg. staging ${NC}\n"
	exit 1
fi

# load configuration file

printf "\n${YELLOW}Loading config for $1 ${NC}\n"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CONFIG_FILE_NAME="${DIR}config/config-$1"

if [ ! -f $CONFIG_FILE_NAME ]; then
	printf "\n${RED}Error: config file not found: $CONFIG_FILE_NAME ${NC}\n"
	exit 1
fi

source $CONFIG_FILE_NAME

# make sure PROJECT_DIR exists and contains project

if [ ! -d "$PROJECT_DIR" ]; then
	printf "\n${YELLOW}Cloning project into $PROJECT_DIR ${NC}\n"
	printf "\n${GREEN}\$ git clone $REPO $PROJECT_DIR ${NC}\n"
	git clone $REPO $PROJECT_DIR
elif [ ! -d "${PROJECT_DIR}.git" ]; then
	printf "\n${RED} Uh oh... The project directory $PROJECT_DIR exists already and is not a git repository. You probably want to remove it. \n"
	exit
fi

printf "\n${GREEN}\$ cd $PROJECT_DIR ${NC}\n"
cd $PROJECT_DIR

# update repository

printf "\n${GREEN}\$ git fetch origin ${NC}\n"
git fetch origin

printf "\n${GREEN}\$ git checkout $BRANCH ${NC}\n"
git checkout $BRANCH

printf "\n${GREEN}\$ git fetch origin $BRANCH ${NC}\n"
git fetch origin $BRANCH

printf "\n${GREEN}\$ git reset --hard FETCH_HEAD ${NC}\n"
git reset --hard FETCH_HEAD

# write version file

printf "\n${YELLOW}Writing VERSION file${NC}\n"
printf "\n${GREEN}\$ git describe --always > VERSION ${NC}\n"
git describe --always > "VERSION"

# remove deploy.sh file
if [ -f "deploy.sh" ]; then
	printf "\n${GREEN}\$ rm deploy.sh ${NC}\n"
	rm deploy.sh
fi

# run composer

printf "\n${YELLOW}Installing dependencies${NC}\n"
printf "\n${GREEN}\$ $COMPOSER_EXEC --no-interaction install ${NC}\n"
eval "$COMPOSER_EXEC install --no-interaction --no-dev"

# create and configure _ss_environment.php if it doesn't exist yet

if [ ! -f ${PROJECT_DIR}_ss_environment.php ]; then
	printf "\n${YELLOW}No _ss_environment.php file found, creating ${PROJECT_DIR}_ss_environment.php from template. Please configure it with your database connection details then run dev/build${NC}\n"
	printf "\n${GREEN}\$ cp ${DIR}_ss_environment.php.default ${PROJECT_DIR}_ss_environment.php ${NC}\n"
	cp ${DIR}"_ss_environment.php.default" ${PROJECT_DIR}"_ss_environment.php"

	function sedeasy {
	  sed -i -e "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
	}

	if [ ! -f $SS_DATABASE_NAME ]; then
		printf "\n${YELLOW}Setting SS_DATABASE_NAME from config ${NC}\n"
		sedeasy "{SS_DATABASE_NAME}" "$SS_DATABASE_NAME" ${PROJECT_DIR}"_ss_environment.php"
	fi

	if [ ! -f $SS_DATABASE_USERNAME ]; then
		printf "\n${YELLOW}Setting SS_DATABASE_USERNAME from config ${NC}\n"
		sedeasy "{SS_DATABASE_USERNAME}" "$SS_DATABASE_USERNAME" ${PROJECT_DIR}"_ss_environment.php"
	fi

	if [ ! -f $SS_DATABASE_PASSWORD ]; then
		printf "\n${YELLOW}Setting SS_DATABASE_PASSWORD from config ${NC}\n"
		sedeasy "{SS_DATABASE_PASSWORD}" "$SS_DATABASE_PASSWORD" ${PROJECT_DIR}"_ss_environment.php"
	fi

	if [ ! -f $SS_DATABASE_PASSWORD ]; then
		printf "\n${YELLOW}Setting _FILE_TO_URL_MAPPING from config ${NC}\n"
		sedeasy "{URL}" "$URL" ${PROJECT_DIR}"_ss_environment.php"
	fi
fi


# clear silverstripe-cache

printf "\n${YELLOW}Clearing silverstripe-cache {NC}\n"
if [ -d ${PROJECT_DIR}silverstripe-cache ]; then
        rm -rf ${PROJECT_DIR}silverstripe-cache
fi
mkdir ${PROJECT_DIR}silverstripe-cache

# get cli-script path

if [[ -f ${PROJECT_DIR}framework/cli-script.php ]]; then
    CLISCRIPT="${PROJECT_DIR}framework/cli-script.php"
else
    CLISCRIPT="${PROJECT_DIR}vendor/silverstripe/framework/cli-script.php"
fi


# run dev/build

printf "\n${YELLOW}Running dev/build${NC}\n"
printf "\n${GREEN}\$ $PHP_EXEC framework/cli-script.php dev/build flush=all ${NC}\n"
eval "$PHP_EXEC $CLISCRIPT dev/build flush=all"

# clear dynamic cache

if [ -d ${PROJECT_DIR}dynamiccache ]; then
	printf "\n${YELLOW}Clearing dynamic cache${NC}\n"
	printf "\n${GREEN}\$ $PHP_EXEC framework/cli-script.php dev/tasks/ClearDynamicCacheTask ${NC}\n"
	eval "$PHP_EXEC $CLISCRIPT dev/tasks/ClearDynamicCacheTask"
fi

# clear cache-include

if [ -d ${PROJECT_DIR}silverstripe-cacheinclude ]; then
        printf "\n${YELLOW}Clearing cache-include {NC}\n"
        printf "\n${GREEN}\$ $PHP_EXEC framework/cli-script.php cache-include/clearall ${NC}\n"
        eval "$PHP_EXEC $CLISCRIPT cache-include/clearall"
fi
