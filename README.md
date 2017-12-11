# terransible

Two Main Directories in this project 

1) terraform (for infrastructure setup)
2) ansible for provisioning the machine


Terraform Directory: 

main.tf - security group for app servers and ELB , launch config and ASG for launching instances
vars.tf - subnets, vpc, keys etc
user-data- installs ansible and pull in the repo to run the roles which install apache and tomcat
aws.tf - provider information 

Ansible Directory:

1) Apache role - installs apache and configures it
2) Tomcat role - installs tomcat and configures it using configure.yml

Both the roles are called from main.yml