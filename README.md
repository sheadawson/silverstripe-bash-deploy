# silverstripe-bash-deploy

A simple Bash deployment script for a specific hosting scenario - shared host that has git installed but not much else.

## Requirements

SilverStripe 3.x or 4.x

## Server Requirements

* git
* ssh access
* port 22 open

## Installation

Copy the deploy-local.sh file to wherever you want to run deployments from, probably into the root of your project, probably rename it deploy.sh. Edit the configuration lines at the top of this file to set your servers ssh access details and the directory where you would like the deployment scripts to be installed on the server.

Now run that file with the configure option. This will install the deployment scripts on the server and prompt you to enter details about the project you are deploying like repo url, database connection details, project folder etc.

```$ ./deploy.sh configure```

## Usage

Once you have configured your environment. You can run

```$ ./deploy.sh nameofconfigfile```
