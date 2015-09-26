#!/usr/local/bin/bash

# Gimme some color!

NC="\033[0m"   
RED="\033[0;31m"      
YELLOW="\033[0;33m"  
GREEN="\033[0;32m"    
 
# Set default variables

CONFIG_DIR="/home/livesour/deploy/config/"
PHP_EXEC="/usr/local/php55/bin/php-cli"
COMPOSER_EXEC="$PHP_EXEC /home/livesour/composer.phar"
RSYNC_EXCLUDE="--exclude=/assets --exclude=/_ss_environment.php --exclude=/.htaccess --exclude=/composer.* --exclude=.git"

# check for valid request

if [ ! $# -eq 2 ]; then
	printf "\n${RED}Error: please provide site and environment/branch argument eg. site.com production${NC}\n"
    exit 1
fi

CONFIG=${CONFIG_DIR}${1}"-"${2}

printf $CONFIG

if [ ! -f $CONFIG ]; then
	printf "\n${RED}Error: no configuration found for site: $1 branch $2 ${NC}\n"
	exit 1
fi

# load configuration file

printf "\n${YELLOW}Loading config for $1 $2 ${NC}\n"
source $CONFIG

# make sure TMP_DIR exists

if [ ! -d "$TMP_DIR" ]; then
	printf "\n${YELLOW}Creating $TMP_DIR ${NC}\n"
	printf "\n${GREEN}\$ mkdir -p $TMP_DIR ${NC}\n"
	mkdir -p $TMP_DIR
fi

# make sure TARGET_DIR exists

if [ ! -d "$TARGET_DIR" ]; then
	printf "\n${YELLOW}Creating $TARGET_DIR ${NC}\n"
	printf "\n${GREEN}\$ mkdir -p $TARGET_DIR ${NC}\n"
	mkdir -p $TARGET_DIR
fi

# clone and/or update repository

cd $TMP_DIR
if [ ! -d ".git" ]; then
	printf "\n${YELLOW}.git repository not present, cloning into $TMP_DIR ${NC}\n"
	printf "\n${GREEN}\$ git clone $REPO $TMP_DIR ${NC}\n"
	git clone $REPO $TMP_DIR
else
	printf "\n${YELLOW}git repository present, checking out $BRANCH ${NC}"
	printf "\n${GREEN}\$ git fetch origin ${NC}\n"
	git fetch origin
fi

printf "\n${GREEN}\$ git checkout $BRANCH ${NC}\n"
git checkout $BRANCH

printf "\n${YELLOW}Fetching updates from repository${NC}\n"
printf "\n${GREEN}\$ git fetch origin $BRANCH ${NC}\n"
git fetch origin $BRANCH
printf "\n${GREEN}\$ git reset --hard FETCH_HEAD ${NC}\n"
git reset --hard FETCH_HEAD

# write version file

printf "\n${YELLOW}Writing VERSION file${NC}\n"
printf "\n${GREEN}\$ git describe --always > ${TMP_DIR}VERSION ${NC}\n"
git describe --always > ${TMP_DIR}"VERSION"

# run composer

printf "\n${YELLOW}Installing dependencies${NC}\n"
printf "\n${GREEN}\$ $COMPOSER_EXEC --no-interaction install ${NC}\n"
eval "$COMPOSER_EXEC --no-interaction install"

# rsync

printf "\n${YELLOW}syncing $TMP_DIR to $TARGET_DIR ${NC}\n"
printf "\n${GREEN}\$ rsync -rltgoDzvO $TMP_DIR $TARGET_DIR $RSYNC_EXCLUDE --delete-after ${NC}\n"
rsync -rltgoDzvO $TMP_DIR $TARGET_DIR $RSYNC_EXCLUDE --delete-after 

# devbuild

if [ ! -f ${TARGET_DIR}_ss_environment.php ]; then
	printf "\n${YELLOW}No _ss_environment.php file found, creating ${TARGET_DIR}_ss_environment.php from template. Please configure it with your database connection details then run dev/build${NC}\n"
	printf "\n${GREEN}\$ cp ${CONFIG_DIR}_ss_environment.php.default ${TARGET_DIR}_ss_environment.php ${NC}\n"
	cp ${CONFIG_DIR}"_ss_environment.php.default" ${TARGET_DIR}"_ss_environment.php"
	#todo - prompt for environment config details
else
	printf "\n${YELLOW}Running dev/build${NC}\n"
	printf "\n${GREEN}\$ $PHP_EXEC ${TARGET_DIR}framework/cli-script.php dev/build flush=all ${NC}\n"
	$PHP_EXEC ${TARGET_DIR}"framework/cli-script.php dev/build flush=all"
fi