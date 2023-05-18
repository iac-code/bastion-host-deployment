output "associate_public_ip_address" {
    value = [aws_instance.oxla-ec2-instance.public_ip, aws_instance.oxla-bastion-host.public_ip]
  
}

output "aws_key_pair" {
    sensitive = true
    value = [aws_key_pair.oxla-keypair.public_key ]
  
}