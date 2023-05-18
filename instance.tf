resource "aws_instance" "oxla-ec2-instance" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = "t2.micro"                       #free tier eligible
  availability_zone                    = "us-east-1a"
  instance_initiated_shutdown_behavior = "terminate"
  #key_name                             = aws_key_pair.oxla-keypair.id
  monitoring                           = true
  subnet_id                            = aws_subnet.oxla-private-subnet.id
  tenancy                              = "default"
  ebs_optimized                        = false
  associate_public_ip_address          = false
  iam_instance_profile                 = aws_iam_instance_profile.oxla-instance-profile.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    delete_on_termination = true
    volume_type = "gp2"
  }
  vpc_security_group_ids = [aws_security_group.oxla-ec2-instance-security-group.id]

  tags = {
    Name        = "oxla-private-server"
    Environment = "lab"
  }

}

resource "aws_key_pair" "oxla-keypair" {
  key_name   = "oxla-keypair"
  public_key = file("./oxla-demo-bastion-keys.pub")   #" "
}


resource "aws_instance" "oxla-bastion-host" {
  ami                                  =  data.aws_ami.ubuntu.id
  instance_type                        = "t2.micro"                       #free tier eligible
  availability_zone                    = "us-east-1a"
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.oxla-keypair.id
  monitoring                           = true
  subnet_id                            = aws_subnet.oxla-public-subnet.id
  tenancy                              = "default"
  ebs_optimized                        = false
  associate_public_ip_address          = true
  iam_instance_profile                 = aws_iam_instance_profile.oxla-instance-profile.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    delete_on_termination = true
    volume_type = "gp2"
  }
  vpc_security_group_ids = [aws_security_group.oxla-ec2-instance-security-group.id]

#this scripts executes the jump hosting access.
  provisioner "file" {
    source      = "sample-script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sample-script.sh",
      "/tmp/sample-script.sh args",
    ]
  }

  tags = {
    Name        = "oxla-server"
    Environment = "lab"
  }

}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}