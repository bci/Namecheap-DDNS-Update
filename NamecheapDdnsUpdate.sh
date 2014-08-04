#!/bin/bash
# --------------------------------------------------------------------------------------------
# File: NamecheapDdnsUpdate.sh
# Macintosh bash script to set the ddns ip address of one or more hosts in your domain hosted at namecheap.com
# Created: Kent Behrends, kent@bci.com, 2014-08-01
# Githup: https://github.com/bci/Namecheap-DDNS-Update.git
#
# Description:
#  Send an UPDATE API method to namecheap.com updating on or more A records. On error response, stop processing ans displat the first error.
#  Normal use is as a cron job, but can be run interactively.
#
# In a cron job
# crontab -e
# @hourly /path-to-script      <-- every hour
# */5 * * * * /path-to-script  <-- every 5 minutes
# 
# Configuration:
#  DOMAIN string - name of domain to update
#  PASSWORD string - the password given from NameCheap.com --> My Account --> Manage Domains --> Modify Domain --> Dynamic DNS
#  HOSTS array of strings - the array of hosts to update.
#  EMAIL string - if exists, then an email will be generated on error or change of IP address
#  CACHED_IP_FILE string - path to file holding the last set IP address  
#
# Notes:
# - Warning, if the host is ''. then host '@' will be set!
#
# Example of REST call:
#  GET https://dynamicdns.park-your-domain.com/update?domain=my.domain.com&password=33598fgc98a1dbcd&host=myhost
#
# Example responses:
#
# On Success:
#
#<?xml version="1.0"?>
#<interface-response>
#  <Command>SETDNSHOST</Command>
#  <Language>eng</Language>
#  <IP>1.2.3.4</IP>
#  <ErrCount>0</ErrCount>
#  <ResponseCount>0</ResponseCount>
#  <Done>true</Done>
#  <debug><![CDATA[]]></debug>
#</interface-response>
#
# On error:
#
#<?xml version="1.0"?>
#<interface-response>
#  <Command>SETDNSHOST</Command>
#  <Language>eng</Language>
#  <ErrCount>1</ErrCount>
#  <errors>
#    <Err1>Passwords do not match</Err1>
#  </errors>
#  <ResponseCount>1</ResponseCount>
#  <responses>
#    <response>
#      <ResponseNumber>304156</ResponseNumber>
#      <ResponseString>Validation error; invalid ; password</ResponseString>
#    </response>
#  </responses>
#  <Done>true</Done>
#  <debug><![CDATA[]]></debug>
#</interface-response>
# --------------------------------------------------------------------------------------------
#
# >>>>>>>>>>>>>>>>>>>>>> Start of Configuration >>>>>>>>>>>>>>>>>>>>>>
#
DOMAIN='mydomain.tld'
PASSWORD=''
HOSTS=('myhost1' 'myhost2')
EMAIL=''
CACHED_IP_FILE='/var/tmp/namecheap_ddns_ip_'
#
# <<<<<<<<<<<<<<<<<<<<<< End of Configuration <<<<<<<<<<<<<<<<<<<<<<
#
url="https://dynamicdns.park-your-domain.com/update?domain=${DOMAIN}&password=${PASSWORD}&host="
settingsValidated=true
messages=""
# --------------------------------------------------------------------------------------------
# Validate configuration 
# 1. DOMAIN must be a valid domain
# 2. PASSWORD must not be empty
# 3. HOSTS must be an array
# 4. Must have write access to CACHED_IP_FILE
# --------------------------------------------------------------------------------------------

# - Validate DOMAIN

if [[ ! $DOMAIN =~ ^(([a-zA-Z](-?[a-zA-Z0-9])*)\.)*[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}$ ]]
then
  settingsValidated=false
  messages="${messages}\nValidation error: ${DOMAIN} is not a valid domain name"
fi

# - Validate PASSWORD

if [ -z "$PASSWORD" ]
then
  settingsValidated=false
  messages="${messages}\nValidation error: PASSWORD must not be empty"
fi

# - Validate host names and write access to cache files

for host in "${HOSTS[@]}"
do
  if [[ ! $host =~ ^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]
  then
    settingsValidated=fasle
    messages="${messages}\nValidation error: Host ${host} is not a valid name for a host"
  else
    saveIpFile=${CACHED_IP_FILE}${host}.txt
    if ( [ -e "$saveIpFile" ] || touch "$saveIpFile") && [ ! -w "$saveIpFile" ]
    then
      settingsValidated=false
      messages="${messages}\nValidation error: No write access to cache file ${saveIpFile}"
    fi
  fi
done

# --------------------------------------------------------------------------------------------
# Use curl to generate the GET request to namecheap.com
# --------------------------------------------------------------------------------------------
if [ settingsValidated ]
then
  for host in "${HOSTS[@]}"
  do
    saveIpFile=${CACHED_IP_FILE}${host}.txt
    hostUrl=${url}${host}
    response=$(curl -s ''${hostUrl}'')
    errCount=$(xmllint --xpath '//interface-response/ErrCount/text()' - <<< "$response")
    if [ "$errCount" -eq "0" ]
    then
      ip=$(xmllint --xpath '//interface-response/IP/text()' - <<< "$response")
      oldIp=$(head -n 1 ${saveIpFile})
      if [ "$oldIp" != "$ip" ]
      then
        message="New IP address detected for host ${host}: ${ip}"
        mail -s "$message" $EMAIL </dev/null
        echo "${ip}" >${saveIpFile}
      fi
    else
      errorResponse=$(xmllint --xpath '//interface-response/response/ResponseString/text()' - <<< "$response")
      echo "Error updating DDNS for namecheap.com host ${host}@${DOMAIN}"
      echo "ResponseString: ${errorResponse}"
      echo ${response} | xmllint --format -
    fi
  done
else
  echo -e $messages
  exit 1
fi

