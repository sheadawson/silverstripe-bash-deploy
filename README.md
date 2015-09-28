# silverstripe-bash-deploy

Bash deployment script for SilverStripe. It's pretty simple and fast and suits me. Let me know if it's useful for you or if you have any suggestions to help improve it!

## How does it work, like what does it do?

* This script should be installed on the same server running your website
* You create config files for your deployable sites/branches
* You run command: $ deploy nameofsite branch
* Repository is cloned/updated in temporary directory
* Composer installs dependencies
* Rsync syncs files with target directory
* _ss_environment.php file created/configured if needed
* dev/build run

## Server Requirements

* git 
* composer
* rsync 
* ssh access
* port 22 open

## Installation

* Copy this repository into the ~/deploy directory on your website server
```
git clone git@github.com:sheadawson/silverstripe-bash-deploy.git ~/deploy
```

* Create a nice alias to execute the shell script eg.
```
alias deploy='~/deploy/deploy.sh'
```

## Configuration

* Create a configuration file for each site/branch you are deploying on the server. The config files should be stored in and named in the format 
```
~/deploy/config/nameofsite-branch
```

```
# What are we deploying?
REPO="git@github.com:me/myrepo.git"
BRANCH="uat"

# Where are we pulling/cloning into? 
TMP_DIR="$HOME/deploy/sites/mywebsite/"

# Where are we deploying the files to?
TARGET_DIR="$HOME/public_html/"

# Do you want to automatically set up your _ss_environment.php file?
SS_DATABASE_NAME="mydatabasename"
SS_DATABASE_USERNAME="mydatabaseuser"
SS_DATABASE_PASSWORD="xxxxxxxxxxx"
URL="http://mywebsite.com"

# You may also need to configure any of these defaults
PHP_EXEC="php"
COMPOSER_EXEC="composer.phar"
RSYNC_EXCLUDE="--exclude=/assets --exclude=/_ss_environment.php --exclude=/.htaccess --exclude=/composer.* --exclude=.git"
```

## Usage

* SSH into your server
```
$ deploy nameofsite branch
```


