DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
cd $DIR

# What are we deploying?
read -e -p "What is the url of the repository you will be deploying? " REPO
read -e -p "What branch do you want to deploy? " BRANCH

CONFIG_FILE_IDENTIFIER=$BRANCH
read -e -p "What should the name of the config file be for this environment? " -i $BRANCH CONFIG_FILE_IDENTIFIER
CONFIG_FILE_NAME="config/config-${CONFIG_FILE_IDENTIFIER}"

# Where are we deploying the files to?
read -e -p "Where should the files deploy to? " -i "${HOME}/public_html/${CONFIG_FILE_IDENTIFIER}/" PROJECT_DIR

# Do you want to automatically set up your _ss_environment.php file?
read -e -p "What's your database name? " -i "${USER}_${CONFIG_FILE_IDENTIFIER}" SS_DATABASE_NAME
read -e -p "What's your database user name? " -i "${USER}_user" SS_DATABASE_USERNAME
read -e -p "What's your database password? " SS_DATABASE_PASSWORD
read -e -p "What URL will this project be available at? " URL

# PHP executable
PHP_EXEC="php"
read -e -p "Command used to execute php scripts: " -i "${PHP_EXEC}" PHP_EXEC

# Composer executable
COMPOSER_EXEC="${PHP_EXEC} ${DIR}composer.phar"
read -e -p "Command used to run composer: " -i "${COMPOSER_EXEC}" COMPOSER_EXEC

if [ ! -f "${DIR}composer.phar" ]; then
	# todo only do this if COMPOSER_EXEC is pointing here
	echo "Installing composer"
	curl -sS https://getcomposer.org/installer | php
fi

# Write config file
if [ ! -d "${DIR}config" ]; then
	mkdir "${DIR}config"	
fi

FILE="$DIR$CONFIG_FILE_NAME"

> $FILE
echo -e "REPO=\"$REPO\"" >> $FILE
echo -e "BRANCH=\"$BRANCH\"" >> $FILE
echo -e "PROJECT_DIR=\"$PROJECT_DIR\"" >> $FILE
echo -e "SS_DATABASE_NAME=\"$SS_DATABASE_NAME\"" >> $FILE
echo -e "SS_DATABASE_USERNAME=\"$SS_DATABASE_USERNAME\"" >> $FILE
echo -e "SS_DATABASE_PASSWORD=\"$SS_DATABASE_PASSWORD\"" >> $FILE
echo -e "URL=\"$URL\"" >> $FILE
echo -e "PHP_EXEC=\"$PHP_EXEC\"" >> $FILE
echo -e "COMPOSER_EXEC=\"$COMPOSER_EXEC\"" >> $FILE

echo "Your config file has been created at $FILE. You can now run deploy.sh $CONFIG_FILE_IDENTIFIER"
cat $FILE