Namecheap-DDNS-Update
=====================

Bash script to update the your namecheap.com ddns host. Tested under Macintosh OSX 10.9.4 and RHES 7.0

Getting Started:
----------------
1. Create a A record on namecheap.com for the host you will be updating. _Hint: you can update more then one host, i.e.: @ and www. You may also wish to keep a low TTL value for these hosts, i.e: 60-120_
2. Enable DDNS by Modifing your domain and clicking on the **Dynamic DNS** entry on the left hand menu. Write down the Password string that is assigned to this domain.
3. Edit the section of the script:

```
# >>>>>>>>>>>>>>>>>>>>>> Start of Configuration >>>>>>>>>>>>>>>>>>>>>>
#
DOMAIN='mydomain.tld'
PASSWORD=''
HOSTS=('myhost1' 'myhost2')
EMAIL=''
CACHED_IP_FILE='/var/tmp/namecheap_ddns_ip_'
#
# <<<<<<<<<<<<<<<<<<<<<< End of Configuration <<<<<<<<<<<<<<<<<<<<<<
```
Configuration:
  * `DOMAIN` *string* - name of domain to update
  * `PASSWORD` *string* - the password given from Namecheap.com
  * `HOSTS` *array of strings* - the array of hosts to update
  * `EMAIL` *string* - if exists, then an email will be generated on error or change of IP address
  * `CACHED_IP_FILE` *string* - path to file holding the last set IP address  


Example Configuration (one host):
----------------------
```
DOMAIN='kentswidget.com'
PASSWORD='2138530d9dea58fa'
HOSTS=( devserver )
EMAIL='ddns_notices@kentswidget.com'
CACHED_IP_FILE='/var/tmp/namecheap_ddns_ip_'
```

Example Configuration (three hosts):
----------------------
```
DOMAIN='kentswidget.com'
PASSWORD='2138530d9dea58fa'
HOSTS=('@' 'www' 'devserver')
EMAIL='ddns_notices@kentswidget.com'
CACHED_IP_FILE='/var/tmp/namecheap_ddns_ip_'
```

Usage:
------
_For these examples I will be saving this script in `~/kent/scripts/NamecheapDdnsUpdate.sh`_

- Command line (runs one time)
  1. Open Terminal
  2. Enter the command $`bash ~/kent/scripts/NamecheapDdnsUpdate.sh`


- Finder (runs one time)
  1. Open finder and locate NamecheapDdnsUpdate.sh
  2. Double-click on file


- Cron (runs every hour)
  1. Open Terminal
  2. Enter the command $`crontab -e`
  3. Add a line: `@hourly ~/kent/scripts/NamecheapDdnsUpdate.sh`

Ignore the script - one liner
-----------------------------
_Fill in the domain, password, and host for your account_
- curl line
  * $`curl -s https://dynamicdns.park-your-domain.com/update?domain=my.domain.com&password=33598fgc98a1dbcd&host=myhost`
