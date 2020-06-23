#!/bin/bash
# cloudAccountCreateWithInstanceRole.sh dsmuser dsmpass manager address guiPort region tenant
username=$1
password=$2
tenant=$6
region=$5

# replace this with your DSM IP or FQDN
DSMURL="$3:$4"

echo "#####Login to DSM"
if [[ -z ${tenant} ]]
  then
      SID=`curl -ks -H "Content-Type: application/json" -X POST "https://${DSMURL}/rest/authentication/login/primary" -d '{"dsCredentials":{"userName":"'${username}'","password":"'${password}'"}}'`
  else
      SID=`curl -ks -H "Content-Type: application/json" -X POST "https://${DSMURL}/rest/authentication/login" -d '{"dsCredentials":{"userName":"'${username}'","password":"'${password}'","tenantName":"'${tenant}'"}}'`
fi

curl -ks --cookie "sID=${SID}" -H "Content-Type: application/json" "Accept: application/json" -X POST "https://${DSMURL}/rest/cloudaccounts/aws" -d '{"AddAwsAccountRequest":{"useInstanceRole":true, "seedRegion":"'${region}'"}}'

curl -k -X DELETE https://${DSMURL}/rest/authentication/logout?sID=${SID}

unset SID
unset username
unset password