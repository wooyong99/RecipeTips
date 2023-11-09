# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag}-vpc"
  }
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag}-igw"
  }
}

# NAT_EIP
resource "aws_eip" "nat-eip" {
  domain     = "vpc"

  tags = {
    Name = "${var.tag}-nat-eip"
  }

  lifecycle {
  create_before_destroy = true
  }
}

# DB_Bastion_EIP
resource "aws_eip" "db-bastion-eip" {
  instance = aws_instance.db_bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.tag}-db-bastion-eip"
  }
}

# Management_Bastion_EIP
resource "aws_eip" "mgmt-bastion-eip" {
  instance = aws_instance.mgmt_bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.tag}-mgmt-bastion-eip"
  }
}


# Jenkins_EIP
resource "aws_eip" "jenkins-eip" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.tag}-jenkins-eip"
  }
} 


# NAT
resource "aws_nat_gateway" "recipe-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.pub_sub_c.id

  tags = {
    Name = "${var.tag}-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Public Routing Table
resource "aws_route_table" "pub_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.tag}-pub-rtb"
  }
}


# public route table association
resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.pub_sub_a.id
  route_table_id = aws_route_table.pub_rtb.id
}

resource "aws_route_table_association" "pub_c" {
  subnet_id      = aws_subnet.pub_sub_c.id
  route_table_id = aws_route_table.pub_rtb.id
}

resource "aws_route_table_association" "alb_pub_a" {
  subnet_id      = aws_subnet.alb_pub_sub_a.id
  route_table_id = aws_route_table.pub_rtb.id
}

resource "aws_route_table_association" "alb_pub_c" {
  subnet_id      = aws_subnet.alb_pub_sub_c.id
  route_table_id = aws_route_table.pub_rtb.id
}


# Private Route Table
resource "aws_route_table" "pri_rtb_a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.recipe-nat.id
  }

  tags = {
    Name = "${var.tag}-pri-rtb-a"
  }
  depends_on = [aws_nat_gateway.recipe-nat]
}

resource "aws_route_table" "pri_rtb_c" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.recipe-nat.id
  }

  tags = {
    Name = "${var.tag}-pri-rtb-c"
  }
  depends_on = [aws_nat_gateway.recipe-nat]
}


# private_route_table association
resource "aws_route_table_association" "mgmt_sub_asso_a" {
  subnet_id      = aws_subnet.mgmt_sub_a.id
  route_table_id = aws_route_table.pri_rtb_a.id
}

resource "aws_route_table_association" "mgmt_sub_asso_c" {
  subnet_id      = aws_subnet.mgmt_sub_c.id
  route_table_id = aws_route_table.pri_rtb_c.id
}

resource "aws_route_table_association" "node_sub_asso_a" {
  subnet_id      = aws_subnet.node_sub_a.id
  route_table_id = aws_route_table.pri_rtb_a.id
}

resource "aws_route_table_association" "node_sub_asso_c" {
  subnet_id      = aws_subnet.node_sub_c.id
  route_table_id = aws_route_table.pri_rtb_c.id
}

resource "aws_route_table_association" "db_sub_asso_a" {
  subnet_id      = aws_subnet.db_sub_a.id
  route_table_id = aws_route_table.pri_rtb_a.id
}

resource "aws_route_table_association" "db_sub_asso_c" {
  subnet_id      = aws_subnet.db_sub_c.id
  route_table_id = aws_route_table.pri_rtb_c.id
}

resource "aws_route_table_association" "redis_sub_asso_a" {
  subnet_id      = aws_subnet.redis_sub_a.id
  route_table_id = aws_route_table.pri_rtb_a.id
}

resource "aws_route_table_association" "redis_sub_asso_c" {
  subnet_id      = aws_subnet.redis_sub_c.id
  route_table_id = aws_route_table.pri_rtb_c.id
}