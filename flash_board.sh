#!/bin/bash
set -euo pipefail

feather_ip=$1
feather_pass=freedom
device_dir='/opt/feather_kernel'  # Path on jetson nano to copy/rebuild kernel

# Remove the temp directory on the board if it exists, then copy new data over
sshpass -p${feather_pass} ssh -t feather@${feather_ip} "rm -rf ${device_dir}"
sshpass -p${feather_pass} scp -r ../feather_jetson_kernel feather@${feather_ip}:${device_dir}


sshpass -pfreedom ssh -t feather@192.168.1.22 "rm -rf /opt/feather_jetson_kernel"