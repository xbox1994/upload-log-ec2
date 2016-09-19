#!/usr/bin/env bash
rm -rf ~/upload_log4ec2
mkdir -p ~/upload_log4ec2
/bin/tar -xvf /tmp/upload_log4ec2.tar -C ~/upload_log4ec2
~/upload_log4ec2/upload_stop.sh
~/upload_log4ec2/upload_start.sh "$1"