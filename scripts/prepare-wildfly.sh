#!/bin/bash
##
##

set -e

TAG="[PREPARE-WILDFLY]: "

## Some logging unification
function logInfo(){
    echo "${TAG} $1"
}


WILDFLY_BINARY_VERSION="wildfly-9.0.2.Final"
WILDFLY_BINARY_URL="http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz"
WILDFLY_MODULES_URL="http://sso-dev-evl-iam.ptin.corppt.com/downloads/jboss-eap-modules-0.0.1.tar.gz"
WILDFLY_HOME="/opt/wildfly"
WILDFLY_USER="wildfly"
WILDFLY_GROUP="jboss"
WILDFLY_CONFIG_PATH="/etc/wildfly"


logInfo "Prepare /opt"
mkdir -p /opt && RES=$?
cd /opt

logInfo "Fetch Binary"
wget ${WILDFLY_BINARY_URL}

logInfo "Expand Binaries"
tar -xzf ${WILDFLY_BINARY_VERSION}.tar.gz
rm ${WILDFLY_BINARY_VERSION}.tar.gz
## Unify the path
mv  ${WILDFLY_BINARY_VERSION} wildfly
## But save the current version
echo ${WILDFLY_BINARY_VERSION} >> /opt/wildfly/VERSION


logInfo "Setting up Environment"
addgroup -S ${WILDFLY_GROUP}
adduser -S -D  -H -h /home/wildfly -s /bin/bash -G ${WILDFLY_GROUP} ${WILDFLY_USER}
chown -R  ${WILDFLY_USER}:${WILDFLY_GROUP}  /opt/wildfly







logInfo "Configuring JBoss Standalone to listen on any address"
sed -i 's/<inet-address value="${jboss.bind.address.management:127.0.0.1}"\/>/<any-address\/>/g' \
        ${WILDFLY_HOME}/standalone/configuration/standalone.xml
sed -i 's/<inet-address value="${jboss.bind.address:127.0.0.1}"\/>/<any-address\/>/g' \
        ${WILDFLY_HOME}/standalone/configuration/standalone.xml


logInfo "Adding Administrator user admin:[Abc!12345]"
# set admin user to jboss
${WILDFLY_HOME}/bin/add-user.sh admin Abc!12345 --silent



# enable debug
## sed -i '9i\ DEBUG_MODE=true' ${WILDFLY_HOME}/bin/standalone.sh
## Not forcing debug mode
## standalone.sh  --debug [port] 
