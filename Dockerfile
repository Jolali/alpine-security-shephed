FROM tomcat:alpine

#PASSWORDS
ENV keystorePass=CowSaysMoo mysqlPass=CowSaysMoo

WORKDIR /tmp
#PACKAGES & BINARIES
RUN apk add --update openssh wget mysql mysql-client mongodb mongodb-tools && rm -rf /var/cache/apk/* && \
    wget --quiet https://github.com/OWASP/SecurityShepherd/releases/download/v3.0/owaspSecurityShepherd_V3.0.Manual.Pack.zip && \
    mkdir shepherd && \
    unzip -d shepherd owaspSecurityShepherd_V3.0.Manual.Pack.zip && \
    dos2unix shepherd/*.sql

WORKDIR /usr/local/tomcat
#SETUP TOMCAT
RUN rm -rf webapps/* \
    mv /tmp/shepherd/ROOT.war webapps

RUN mysql_install_db --user=root --rpm && \
    mysqld --user=root