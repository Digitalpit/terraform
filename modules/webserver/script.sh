#!/bin/bash

sudo yum update -y && sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
echo '<!doctype html>
<html lang="en"><h1> Home page! </h1></br>
<h3>(App instance)</h3>
</html>' | sudo tee /usr/share/nginx/html/index.html