output "associate_public_ip_address" {
    value = [aws_instance.oxla-ec2-instance.public_ip, aws_instance.oxla-bastion-host.public_ip]
  
}
