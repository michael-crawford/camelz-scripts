#!/bin/bash -e
# GitHub Enterprise Bootstraping
# date:  Nov,3,2016
# purpose: UserData and or scripts should be stored here, but only for source code revision purposes and CloudFormation templates should always refer to 'quickstart-reference' S3 bucket
#
# This is a slight modification to the script specified in the QuickStart, containing these changes:
# 1. The License file is downloaded separately by a prior cfn-init step, to the same location used in the original version of this script, /tmp/github-enterprise.ghl
# 2. The Instance is created in a private subnet for internal use, so we must obtain the private IP from the meta-data service.

# Configuring the GitHub Enterprise server
DATE=`date +%d-%m-%Y`
date >/root/install_date

##########################################
# Check status function
##########################################
function chkstatus () {
if [ $1 -eq $2 ]
then
  echo "Script $0 [PASS]"
else
  echo "Script $0 [FAILED]" >&2
  exit 1
fi
}

###########################################
#  Configure the GitHub Enterprise server
###########################################

AWS_CMD='/usr/local/bin/aws'
EC2_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

# ARGS for script
# 1: GHE_CONSOLE_PASSWORD

# In this variant of the script, the license file is downloaded prior
# to running this script, so confirm it exists
[ ! -r /tmp/github-enterprise.ghl ] && exit 1

sleep 25
#Upload the license and set the GitHub Enterprise Admin password
START_SETUP=`curl -o /dev/null -i -k -L --write-out '%{http_code}' -F license=@/tmp/github-enterprise.ghl -F password=$1 -X POST https://${EC2_IP}:8443/setup/api/start`
RETURN_START=`echo ${START_SETUP} | awk -F' ' '{print $NF}'`
echo "HTTP status code for start setup: " ${RETURN_START}
chkstatus ${RETURN_START} 202
echo "Return from chkstatus:" $?
[[ $? -ne 0 ]] && exit 1

# Initiate the configuration process
INITIATE_CONFIG=$(curl -i -k -L --write-out '%{http_code}' --silent -X POST https://api_key:$1@localhost:8443/setup/api/configure)
RETURN_INITIATE=`echo ${INITIATE_CONFIG} | awk -F' ' '{print $NF}'`
echo "HTTP status code for initiate config: " ${RETURN_INITIATE}
chkstatus ${RETURN_INITIATE} 202
echo "Return from chkstatus:" $?
[[ $? -ne 0 ]] && exit 1

# Check the configuration status and continue to check until the configuration is complete
CONFIG_STATUS=`curl -k -L https://api_key:$1@localhost:8443/setup/api/configcheck | awk -F, '{print $NF}' | awk -F: '{print $NF}' |tail -n1 `
while [[ ${CONFIG_STATUS} != *'DONE'* ]]; do
  sleep 2
  echo date
  echo 'Waiting for config status to contain done for Reloading application services'
  echo ${CONFIG_STATUS}
  CONFIG_STATUS=`curl -k -L https://api_key:$1@localhost:8443/setup/api/configcheck | awk -F, '{print $NF}' | awk -F: '{print $NF}' |tail -n1 `
done

echo "The exit code for this script:" $?
