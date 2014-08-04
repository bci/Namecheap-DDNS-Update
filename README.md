Namecheap-DDNS-Update
=====================

Macintosh bash script to set the ddns ip address of one or more hosts in your domain hosted at namecheap.com

Getting Started:
----------------
1. Create a A record on namecheap.com for the host you will be updating. _Hint: you can update more then one host, i.e.: @ and www_
2. Enable DDNS by Modifing your domain and clicking on the Dynamic DNS entry on the left hand menu. Note the Password string that is assigned to this domain.
3. Edit the section of the script:

```
# >>>>>>>>>>>>>>>>>>>>>> Start of Configuration >>>>>>>>>>>>>>>>>>>>>>
#
DOMAIN='mydomain.tld'
PASSWORD=''
HOSTS=('myhost1' 'myhost2')
EMAIL='kent@bci.com'
CACHED_IP_FILE='/var/tmp/namecheap_ddns_ip_'
#
# <<<<<<<<<<<<<<<<<<<<<< End of Configuration <<<<<<<<<<<<<<<<<<<<<<
```
