FROM tomcat:alpine

#PASSWORDS
ENV keystorePass=CowSaysMoo mysqlPass=CowSaysMoo

WORKDIR /tmp
#PACKAGES & BINARIES
RUN apk add --update bash openssh wget mysql mysql-client mongodb mongodb-tools && rm -rf /var/cache/apk/* && \
    wget --quiet https://github.com/OWASP/SecurityShepherd/releases/download/v3.0/owaspSecurityShepherd_V3.0.Manual.Pack.zip && \
    mkdir shepherd && \
    unzip -d shepherd owaspSecurityShepherd_V3.0.Manual.Pack.zip && \
    dos2unix shepherd/*.sql

RUN mysql_install_db --user=root && \
    mkdir -p /run/mysqld && \
    /bin/bash -c "mysqld --user=root &" && \
    sleep 5 && \
    mysqladmin -u root password "CowSaysMoo" && \
    mysql --user=root -e "source shepherd/coreSchema.sql" --force --password=CowSaysMoo && \
    mysql --user=root -e "source shepherd/coreSchema.sql" --force --password=CowSaysMoo

RUN mkdir -p /data/db && \
    bash -c "mongod &" && \
    sleep 5 && \
    mongo shepherd/mongoSchema.js

WORKDIR /usr/local/tomcat
#SETUP TOMCAT

ADD templates/server.xml conf/server.xml
ADD templates/web.xml conf/web.xml
RUN rm -rf webapps/* &&\
    dos2unix conf/server.xml && \
    dos2unix conf/web.xml && \
    mv /tmp/shepherd/ROOT.war webapps && \
    keytool -genkey -alias tomcat -keyalg RSA -dname "CN=OwaspShepherd,OU=Security Shepherd,O=OWASP,L=Baile Átha Cliath,ST=Laighin,C=IE" -storepass passw0rd -keypass passw0rd -storetype JKS && \
    #wget --quiet https://raw.githubusercontent.com/OWASP/SecurityShepherd/dev/SecurityShepherdCore/setupFiles/tomcatShepherdSampleServer.xml -O conf/server.xml && \
    #wget --quiet https://raw.githubusercontent.com/OWASP/SecurityShepherd/dev/SecurityShepherdCore/setupFiles/tomcatShepherdSampleWeb.xml -O conf/web.xml && \
    sed -i "s/____.*____/\/root\/.keystore/g" conf/server.xml && \
    sed -i "s/___shepherd___/passw0rd/g" conf/server.xml

EXPOSE 8080 8443 3306 27017

CMD mysqld_safe --user=root & \
    mongod & \
    /usr/local/tomcat/bin/startup.sh