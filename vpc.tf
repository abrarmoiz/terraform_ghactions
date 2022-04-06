#vpc
resource "aws_vpc" "docker_swarm_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    project = "docker_vpc"
  }
}


# subnets
resource "aws_subnet" "docker_swarm_public_subnet" {
  vpc_id     = "${aws_vpc.docker_swarm_vpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "docker_public_SN1"
  }
}


resource "aws_subnet" "docker_swarm_private_subnet" {
  vpc_id     = "${aws_vpc.docker_swarm_vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "docker_swarm_private_SN2"
  }
}

# Internet GW
resource "aws_internet_gateway" "docker_swarm_gw" {
  vpc_id = "${aws_vpc.docker_swarm_vpc.id}"

  tags = {
    Name = "docker_swarm_IG"
  }
}

# route tables
resource "aws_route_table" "docker_swarm_rt" {
  vpc_id =  "${aws_vpc.docker_swarm_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.docker_swarm_gw.id}"
  }

  tags = {
    Name = "docker_swarm_RT"
  }
}


resource "aws_route_table_association" "public_subnet" {
  subnet_id      = "${aws_subnet.docker_swarm_public_subnet.id}"
  route_table_id = "${aws_route_table.docker_swarm_rt.id}"
}

# Security Groups
resource "aws_security_group" "docker_swarm_SG" {
  name        = "docker_swarm_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.docker_swarm_vpc.id}"

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["10.0.1.0/24"]
  }

}

resource "aws_security_group_rule" "ssh_ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  security_group_id = "${aws_security_group.docker_swarm_SG.id}"
  protocol          = "tcp"
}

resource "aws_instance" "docker_swarm_1" { 
  ami           = "ami-01cc34ab2709337aa"
  key_name      = "${aws_key_pair.bastion_key.key_name}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.docker_swarm_SG.id}"]
  subnet_id = "${aws_subnet.docker_swarm_public_subnet.id}"
    tags = {
      account = "docker_swarm_ec2"
    }
} 

resource "aws_instance" "docker_swarm_2" { 
  ami           = "ami-01cc34ab2709337aa"
  key_name      = "${aws_key_pair.bastion_key.key_name}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.docker_swarm_SG.id}"]
  subnet_id = "${aws_subnet.docker_swarm_public_subnet.id}"
    tags = {
      account = "docker_swarm_ec2"
    }
} 

resource "aws_instance" "docker_swarm_3" { 
  ami           = "ami-01cc34ab2709337aa"
  key_name      = "${aws_key_pair.bastion_key.key_name}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.docker_swarm_SG.id}"]
  subnet_id = "${aws_subnet.docker_swarm_public_subnet.id}"
    tags = {
      account = "docker_swarm_ec2"
    }
} 

resource "aws_key_pair" "bastion_key" {
  key_name   = "docker_bastion"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQ/ABw8ZLGzL9UCRrls4J6+Q+N2N9RyNjI8BgX8Slg5ppzRab9oceRpNTg5cdkXlWAalS1Kdfp1NMELQd+W0SezoKLjP9bx+kRj7jIOcnRQ2NV80mkqd32ROc80B2jOALvM4yAA4IZgaT1ShoKmbulBdMCPGlk4Oi6fKY3+5RDoS+0GYJ9wZ/JJEYiZIccmAe47OPqMYVgAfi1FJcvuAG6sBiNvSMQsr7yx4ookbZTek1z226A4halAJldIRbwtzhajmdertSTN7oBWKmU7Mck8a5wLINphji88/tKIQav1+Wq41hwn0ME7cdKO2fqfAD5Ug1qZnN5rxq/oXGEyYNc+VA3+Rc1bDRsKFILLkmUnMaPj6Mzw8f06yI29oQ/szSp/mJzz6x0+pHe/QLA0s4hSdYQBhrg1XEeECPrnxLssxYgopS+/qxeEFJ2iLenvi44krWPvTFbTA63VVYGc7NMGz1w0eGgstg45nCUh3CrtQzKrsyeaM4aUzEiO4frgJGKR+ZKmtwLdPkcQtVZiaCZN/8HAj2rgEJNnEhUS4wNqLKXvKoNxw4OZmLiL+ZdXCAyfB5Pw6f+jNxPIqb2Xjt16FGeLUJJyF0q1CKcFFSTrviOKN0nOJpaGLqk6lFDzIMAATRNQiVI0NGavIJfhrPLtxNrYuSsqYsbNddWoWraFw== abrar.moiz@gmail.com"
}

terraform {
  backend "s3" {
    bucket = "334644556568568568-statefile"
    key    = "path/to/state-file"
    region = "us-east-1"
  }
}