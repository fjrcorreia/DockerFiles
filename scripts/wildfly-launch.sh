#!/bin/sh
HOSTNAME=${HOSTNAME:-$(hostname)}
JBOSS_CONFIG=${JBOSS_CONFIG:-standalone.xml}
JBOSS_OPTS=${JBOSS_OPTS:-}
IPADDR=${IPADDR:-$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | sort | head -n 1)}


JBOSS_JAVA_OPTS="-Djboss.bind.address=$IPADDR -Djboss.bind.address.management=$IPADDR"
JBOSS_JAVA_OPTS="${JBOSS_JAVA_OPTS} -Djboss.node.name=$HOSTNAME"



JBOSS_USER=${JBOSS_USER:-admin}
JBOSS_PASSOWRD=${JBOSS_PASSOWRD:-Abc!12345}




JBOSS_INIT_DOMAIN=.init-domain




## JBoss Wildfly as a Service config
JBOSS_PIDFILE=/tmp/jboss.pid


start_jboss() {
    echo "I [WILDFLY-INIT]: starting jboss as a backgroung process for configuration"
    LAUNCH_JBOSS_IN_BACKGROUND=1 JBOSS_PIDFILE=/tmp/jboss.pid ${JBOSS_HOME}/bin/standalone.sh -c standalone.xml &
    #sleep 5
    until $(nc -z  localhost 9990)
    do
      echo "I [WILDFLY-INIT]: Waiting for server to start!"
      sleep 1
    done

}

## STOP JBOSS as a Service
stop_boss() {
  echo "I [WILDFLY-INIT]: Stopping JBOSS on background!"
  count=0;

  echo "PIDF: $JBOSS_PIDFILE"
  if [ -f $JBOSS_PIDFILE ]; then
    kpid=$(cat $JBOSS_PIDFILE)
    ## 30 seconds wait
    let kwait=30

    echo "PID: $kpid"
    # Try issuing SIGTERM
    kill -15 $kpid
    until [ `ps --pid $kpid 2> /dev/null | grep -c $kpid 2> /dev/null` -eq '0' ] || [ $count -gt $kwait ]
    do
      sleep 1
      let count=$count+1;
    done

    if [ $count -gt $kwait ]; then
      kill -9 $kpid
    fi
  fi
  rm -f $JBOSS_PIDFILE
  echo "I [WILDFLY-INIT]: Stopped!"
}


assert_result() {
    if [ $1 -ne 0 ]
    then
        echo "E [WILDFLY-INIT]: Failed to prepare jboss"
        stop_jboss
        exit 1
    fi
}



#######################################
# Verify if there is any valid init scritps in the /docker-init.d folder
# Arguments:
#   None
# Returns:
#   success - if there is any scripts
#   fail - if no scripts were found
#######################################
has_init_scripts(){
  if [ $(ls /docker-init.d/*.sh 2&> /dev/null | wc -l ) -gt 0 ]  \
     || [ $(ls /docker-init.d/*.cli 2&> /dev/null | wc -l ) -gt 0 ]
  then
    return 0
  fi

  return 1
}






###############################################################################
# Perform container initializatoin
#
#  - Creates an adminstration user, usefull for remote depoloy
#  - Verifies if there are any init action to be performed (/docker-init.d)
###############################################################################
if [ ! -e ${JBOSS_HOME}/$JBOSS_INIT_DOMAIN ]
then
    JBOSS_INIT_ACTIONS=""

    JBOSS_CLI_CMD="${JBOSS_HOME}/bin/jboss-cli.sh --connect "

    if [ ! -z $JBOSS_PASSOWRD ]
    then
        echo "I [WILDFLY-INIT]: Adding Administrator User: {${JBOSS_USER}}"
        # set admin user to jboss
        ${JBOSS_HOME}/bin/add-user.sh ${JBOSS_USER} ${JBOSS_PASSOWRD} --silent
        if [ $? -ne 0 ]
        then
           echo "E [WILDFLY-INIT]: Failed to Create Administration USER"
           exit 1
        fi
        JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS}SET ADMINISTRATOR: ${JBOSS_USER}\n"
        JBOSS_CLI_CMD="$JBOSS_CLI_CMD"
    fi


    ## Start the server only if necessary
    if has_init_scripts
    then
        start_jboss
        for i in /docker-init.d/*
        do
            case "$i" in
    		        *.sh)
    		            echo "I [WILDFLY-INIT]: Running Script: $i";
    		            JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS} Exec Script [$i]:";
    		            . "$i" && RES=$? && assert_result $RES
    		            JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS} OK\n";
    		        ;;
        				*.cli)
        				    echo "I [WILDFLY-INIT]: Running Commands: $i";
        		            JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS} Exec Commands [$i]:";
        				    ${JBOSS_CLI_CMD} < $i && RES=$? && assert_result $RES
        		            JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS} OK\n";
        				;;
        				*)
        				    echo "I [WILDFLY-INIT]: Ignoring File: $i"
        				;;
    			  esac

      	done
      	stop_boss
    else
      echo "I [WILDFLY-INIT]: No init scripts found!"
    fi

    JBOSS_INIT_ACTIONS="${JBOSS_INIT_ACTIONS} COMPLETED!\n";
  	echo -e ${JBOSS_INIT_ACTIONS} > ${JBOSS_HOME}/${JBOSS_INIT_DOMAIN}

fi





echo "Starting JBoss Wildfly..."
exec ${JBOSS_HOME}/bin/standalone.sh -c $JBOSS_CONFIG ${JBOSS_JAVA_OPTS} ${JBOSS_OPTS}
