#!/usr/bin/env bash
tar -cvf upload_log4ec2.tar upload_start.sh upload_stop.sh wty.pem

domain="$1.accounts-service.thoughtworks.net"
if [ "$1" == "prod" ]; then
	domain="accounts-service.thoughtworks.net"
fi

scp -o StrictHostKeychecking=no upload_log4ec2.tar ubuntu@"$domain":/tmp/
scp -o StrictHostKeychecking=no upload_deploy_remote.sh ubuntu@"$domain":/tmp/
ssh -o StrictHostKeychecking=no ubuntu@"$domain" 'sudo sh /tmp/upload_deploy_remote.sh as'

#ssh -o StrictHostKeychecking=no ubuntu@ci.accounts-service.thoughtworks.net 'sudo ~/upload_log4ec2/upload_stop.sh'