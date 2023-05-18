resource "aws_subnet" "oxla-public-subnet" {
  vpc_id     = aws_vpc.oxla-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "oxla-private-subnet" {
  vpc_id     = aws_vpc.oxla-vpc.id
  cidr_block = "10.0.128.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "oxla-public-subnet"
  }
}


resource "aws_route_table" "oxla-route-table" {
  vpc_id = aws_vpc.oxla-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_internet_gateway.oxla-internet-gateway.id
  }

  # route {
  #   ipv6_cidr_block        = ["::/0"]
  #   egress_only_gateway_id = ["::0"]
  # }

  tags = {
    Name = "oxla-route-table"
  }
}

resource "aws_route_table_association" "oxla-route-table-association" {
  subnet_id      = aws_subnet.oxla-public-subnet.id
  route_table_id = aws_route_table.oxla-route-table.id
}

resource "aws_route_table" "oxla-private-route-table" {
  vpc_id = aws_vpc.oxla-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oxla-internet-gateway.id
  }

  tags = {
    Name = "oxla-private-route-table"
  }
}

resource "aws_route_table_association" "oxla-private-route-table-association" {
  subnet_id      = aws_subnet.oxla-private-subnet.id
  route_table_id = aws_route_table.oxla-private-route-table.id
}

resource "aws_internet_gateway" "oxla-internet-gateway" {
  vpc_id = aws_vpc.oxla-vpc.id

  tags = {
    Name = "oxla-internet-gateway"
  }
}

# resource "aws_internet_gateway_attachment" "oxla-internet-gateway-attachment" {
#   internet_gateway_id = aws_internet_gateway.oxla-internet-gateway.id
#   vpc_id              = aws_vpc.oxla-vpc.id
# }

resource "aws_security_group" "oxla-bastion-security-group" {
  name        = "bastion-allow-public-traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.oxla-vpc.id

  ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "443"
    to_port          = "443"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_security_group" "oxla-ec2-instance-security-group" {
  name        = "ec2-instance-security-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.oxla-vpc.id

  ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "443"
    to_port          = "443"
    protocol         = "tcp"
    security_groups = [ aws_security_group.oxla-bastion-security-group.id]

  }

  ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    security_groups = [ aws_security_group.oxla-bastion-security-group.id]
  }

   ingress {
    description      = "Public-Traffic-TLS"
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    security_groups = [ aws_security_group.oxla-bastion-security-group.id]
  } 

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-bastion-host"
  }
}