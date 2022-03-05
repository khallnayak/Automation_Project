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
	timestamp=$(date '+%d%m%Y-%H%M%S')
	short_file=mahij-http-logs-$timestamp.tar
	filename=/tmp/$short_file
	s3_bucket=upgrad-mahij
	web_file=/var/www/html/inventory.html
	tar -cf $filename /var/log/apache2/*.log
	filesize=$(du -h $filename | cut -f 1)
	if [ -f $web_file ]
	then
		echo "httpd-logs    $timestamp    tar	$filesize" >> $web_file
	else
		echo "<pre> LogType	DateCreated		Type	Size" > $web_file
		echo "httpd-logs $timestamp tar $filesize" >> $web_file
	fi
	aws s3 cp $filename s3://${s3_bucket}/mahij-http-logs-$(date '+%d%m%Y-%H%M%S').tar
fi

