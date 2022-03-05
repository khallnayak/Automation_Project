#! /bin/bash

sudo apt update -y

dpkg -l apache2

if [ $? -ne 0 ]
then
	sudo apt install -y apache2
fi

systemctl is-active --quiet apache2

if [ $? -ne 0 ]
then
	echo "service unable to start"
else
	filename=/tmp/mahij-http-logs-$(date '+%d%m%Y-%H%M%S').tar
	short_file=mahij-http-logs-$(date '+%d%m%Y-%H%M%S').tar
	s3_bucket=upgrad-mahij
	tar -cf $filename /var/log/apache2/*.log
	aws s3 cp $filename s3://${s3_bucket}/mahij-http-logs-$(date '+%d%m%Y-%H%M%S').tar
fi

