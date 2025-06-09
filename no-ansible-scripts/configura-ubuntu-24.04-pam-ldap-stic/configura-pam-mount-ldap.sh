#!/bin/bash --login


apt-get install -y libpam-ldap ldap-auth-client ldap-auth-config libnss-ldapd ldap-utils nscd libpam-script cifs-utils nfs-common sssd
# auth-client-config
#chown root.root /etc/sssd/sssd.conf
#chmod go-r  /etc/sssd/sssd.conf
service sssd restart
cd files
rsync -av . /
chmod 0600 /etc/sssd/sssd.conf

