# Create the VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Production VPC"
  }
}

# Create public and private subnets
# To provide HA, we create the subnets redundant 
# and position them in separate AZs. 
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet1_cidr_block
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Public Subnet 1a"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet2_cidr_block
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Public Subnet 1b"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Private Subnet 1a"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet2_cidr_block
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Private Subnet 1b"
  }
}

# Create the internet gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Prod VPC IGW"
  }
}

# Create an elastic IP for NAT gw
resource "aws_eip" "nat_gw_elastic_ip" {
  depends_on = [aws_internet_gateway.internet_gw]
}

# Create the NAT gateway (public NAT)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gw]
}

# Create Route Tables
# public RT uses internet gateway to access internet
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name = "Public route table"
  }
}

# private RT uses nat gateway to access internet
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private route table"
  }
}

# Associate the route tables with subnets 
resource "aws_route_table_association" "public_rt_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_rt_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_rt_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_rt_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route.id
}

# Define security groups
resource "aws_security_group" "jenkins_sec_gr" {

  name        = "Jenkins Security Group"
  description = "Jenkins GUI and SSH access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins GUI access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins SSH access"
  }

  /* From TF Documentation: NOTE on Egress rules:
  By default, AWS creates an ALLOW ALL egress rule when creating a new Security Group inside of a VPC. 
  When creating a new Security Group inside a VPC, Terraform will remove this default rule, 
  and require you specifically re-create it if you desire that rule.
  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # If you select a protocol of -1 (semantically equivalent to all, which is not a valid value here), 
  # you must specify a from_port and to_port equal to 0. 

  tags = {
    Name = "Jenkins Sec.Group"
  }
}

resource "aws_security_group" "sonarqube_sec_gr" {
  name        = "Sonarqube Security Group"
  description = "Sonarqube GUI port 9000 and SSH port 22 access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = var.sonarqube_port
    to_port     = var.sonarqube_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Sonarqube GUI access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Sonarqube SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sonarqube Sec.Group"
  }
}

resource "aws_security_group" "ansible_sec_gr" {
  name        = "Ansible Security Group"
  description = "Ansible SSH port 22 access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ansible SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ansible Sec.Group"
  }
}

resource "aws_security_group" "grafana_sec_gr" {
  name        = "Grafana Security Group"
  description = "Grafana GUI port 3000 and SSH port 22 access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = var.grafana_port
    to_port     = var.grafana_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana GUI access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Grafana Sec.Group"
  }
}

resource "aws_security_group" "application_sec_gr" {
  name        = "Application Security Group"
  description = "Application HTTP port 80 and SSH port 22 access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = var.web_app_port
    to_port     = var.web_app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web application access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Application Sec.Group"
  }
}

# Create Load Balancer Security Group
resource "aws_security_group" "loadbalancer_sec_gr" {
  name        = "Loadbalancer Security Group"
  description = "Loadbalancer http port 80 access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = var.web_app_port
    to_port     = var.web_app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web application access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Loadbalancer Sec.Group"
  }
}

# Create Network Access Lists
resource "aws_network_acl" "network_acl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.web_app_port
    to_port    = var.web_app_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.jenkins_port
    to_port    = var.jenkins_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.sonarqube_port
    to_port    = var.sonarqube_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.grafana_port
    to_port    = var.grafana_port
  }

  tags = {
    Name = "Main ACL"
  }
}

# Create an ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "docker_repository"
  image_tag_mutability = "MUTABLE" # actually, this is unnecessary, its the default 

  image_scanning_configuration {
    scan_on_push = true
  }
}


# Create AWS Key-Pair using manually created existing keys 
resource "aws_key_pair" "ec2_ssh_key" {
  
  key_name   = "ec2_ssh_key"
  public_key = file("${var.ssh_keyfile_name}.pub")
  
}

# Create EC2 Instance for Jenkins
resource "aws_instance" "jenkins" {

  ami                    = var.aws_image_id
  instance_type          = var.instance_type
  availability_zone      = "eu-central-1a"
  subnet_id              = aws_subnet.public_subnet1.id
  key_name               = aws_key_pair.ec2_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sec_gr.id]
  user_data              = file("jenkins_install.sh")
  tags = {
    Name = "Jenkins"
  }
  depends_on = [ aws_key_pair.ec2_ssh_key ]

}