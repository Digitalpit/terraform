#!/bin/bash

sudo yum update -y && sudo yum install mysql -y
sudo systemctl start mysql