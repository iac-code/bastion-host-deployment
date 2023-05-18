# Bastion config
Host bastion
# Change the hostname to whatever you get from terraform's output
Hostname ec2-5-55-128-160.us-east-2.compute.amazonaws.com
IdentityFile ~/.ssh/hyperngn_aws_ohio.pem

# ECS cluster machines
Host ecs1
Hostname 20.10.21.217
User ec2-user
IdentityFile ~/.ssh/datamellon-keypair.pem
ForwardAgent yes
ProxyJump bastion

# This section is optional but allows you to reuse SSH connections
Host *
  User ubuntu
   Compression yes
# every 10 minutes send an alive ping
   ServerAliveInterval 60
   ControlMaster auto
   ControlPath /tmp/sample-scripts.sh