#!/bin/bash

# Use this script to execute any extra commands or configuration you want when the container is built
# As an example, I'm aliasing 'httpd' for the convenience of RedHat/CentOS/Windows Apache users.
echo 'alias httpd="apache2ctl"' >> ~/.bashrc
source ~/.bashrc