#!/bin/bash -v

sudo apt-get update
sudo apt-get install nginx -y
echo "hello world <br> <img src='https://s3-ap-southeast-2.amazonaws.com/ga-gameday-${team}/hello.png'/>" > /usr/share/nginx/html/index.html