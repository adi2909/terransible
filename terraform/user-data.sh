#!/bin/bash
#
# Install Ansible and use `ansible-pull` to run the playbook.

set -e
set -x

function main {
  # Set our named arguments.
  declare -r url=$1 playbook=$2

  # Ensure the instance is up-to-date.
  yum update -y

  # Install required packages.
  yum install -y git

  # Install Ansible!
  pip install ansible

  # Download our Ansible repository and run the given playbook.
  /usr/local/bin/ansible-pull --accept-host-key --verbose \
    --url "$url" --directory /var/local/src/instance-bootstrap "$playbook"
}

#
main \
  'https://github.com/adi2909/terransible.git' \
  'ansible/main.yml'