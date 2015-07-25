#!/bin/bash
set -x
##################################################################################
## Single Docker Host DNS setup using dnsmasq
##
## VERSION		:0.0.2
## DATE			:23Jul2015
## Ref[1]		:http://wiredcraft.com/blog/dns-and-docker-containers/
## Ref[2]		:https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/
##################################################################################

#check if docker is running
DOCKER_SERVICE=docker
if pgrep ${DOCKER_SERVICE} >/dev/null 2>&1
  then

# Get the docker host ip and update the DNS
IP=$(ip -o -4 addr list docker0 | perl -n -e 'if (m{inet\s([\d\.]+)\/\d+\s}xms) { print $1 }')

sed -ri "s|__LOCAL_IP__|${IP}|g" /etc/dnsmasq.conf

# Domain name for containers
CONTAINER_DOMAIN=myhadoop-containers.com

# Path to the addn-hosts file
CONTAINER_HOSTS=/docker-container-hosts

echo "# Auto-generated by $0" > $CONTAINER_HOSTS
for CID in `docker ps -q`; do
    IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID`
    NAME=`docker inspect --format '{{ .Config.Hostname }}' $CID`
    echo "$IP  $NAME.$CONTAINER_DOMAIN" >> $CONTAINER_HOSTS
done

# echo 'address=/example.com/xx.xx.xx.xx' >> /etc/dnsmasq.d/0hosts


# Ask dnsmasq to reload addn-hosts
pkill -x -HUP dnsmasq

#### If running in the background to automatically update
#while [ 1 ];
#do
#    sleep 3
#    # kill and restart dnsmasq every three seconds
#    # in case its configuration has changed
#    pkill dnsmasq
#    dnsmasq
#done

  else
	echo "${DOCKER_SERVICE} service is not running!"
fi
