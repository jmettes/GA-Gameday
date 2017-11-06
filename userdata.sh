#!/bin/bash -v

sudo apt-get update
sudo apt-get install nginx -y
echo "hello world" > /usr/share/nginx/html/index.html