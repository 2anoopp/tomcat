#! /bin/bash
# CodeDeploy Application life-cycle 2 : Preparing environment 

# Take backup for latest deployment for emergency restoration
/bin/mv  /opt/webapps.tar.gz  /opt/webapps.tar.gz_toremove
/bin/tar -zcvf /opt/webapps.tar.gz /var/lib/tomcat9/webapps/
exit 0
