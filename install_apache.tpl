#cloud-config
package_upgrade: true
packages:
  - tomcat
  - tomcat-webapps
  - tomcat-admin-webapps
  - tomcat-docs-webapp
  - tomcat-javadoc
  - unzip
write_files:
  - path: /home/root/tomcat-users.xml
    content: |
      <?xml version='1.0' encoding='utf-8'?>
      <tomcat-users>
          <user username="admin" password="%PASS%" roles="manager-gui,admin-gui"/>
      </tomcat-users>
runcmd:
  # Set random Tomcat admin password.
  - TOMCATPASS=`dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`
  - sed -i -e "s/%PASS%/$TOMCATPASS/" /home/root/tomcat-users.xml
  - echo "Tomcat Username  -  admin" > /root/tomcat
  - echo "Tomcat Password  -  $TOMCATPASS" >> /root/tomcat
  - echo -e "\nAccess the managment interface at http://localhost:8080/manager/html" >> /root/tomcat
  - mv /home/root/tomcat-users.xml /usr/share/tomcat/conf/tomcat-users.xml
  - wget https://raw.githubusercontent.com/dbsibmpoc1/ibm-cloud-vm-3tier-app-template/master/DBSystelClusterApp.war
  - unzip DBSystelClusterApp.war -d /var/lib/tomcat/webapps/DBSystelClusterApp
  - sed -i -e "s/MYSQL_PRIVATE_IP/${TF_MYSQL_PRIVATE_IP}/" /var/lib/tomcat/webapps/DBSystelClusterApp/WEB-INF/classes/db.properties
  - systemctl start tomcat
  - systemctl enable tomcat
