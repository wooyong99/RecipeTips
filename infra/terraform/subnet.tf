# Public Subnet
resource "aws_subnet" "pub_sub_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true  # 퍼블릭 IPv4 주소 자동할당 "Default is false"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-pub-sub-2a"
  }
}

resource "aws_subnet" "pub_sub_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-pub-sub-2c"
  }
}

resource "aws_subnet" "alb_pub_sub_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true  # 퍼블릭 IPv4 주소 자동할당 "Default is false"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-alb-pub-sub-2a"
  }
}

resource "aws_subnet" "alb_pub_sub_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-alb-pub-sub-2c"
  }
}

# Private Subnet
resource "aws_subnet" "mgmt_sub_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.11.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-mgmt-sub-2a"
  }
}

resource "aws_subnet" "mgmt_sub_c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.21.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-mgmt-sub-2c"
  }
}

resource "aws_subnet" "jenkins_sub_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.12.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-jenkins-sub-2a"
  }
}

resource "aws_subnet" "jenkins_sub_c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.22.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-jekins-sub-2c"
  }
}


resource "aws_subnet" "node_sub_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.13.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-node-sub-2a"
  }
}

resource "aws_subnet" "node_sub_c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.23.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-node-sub-2c"
  }
}

resource "aws_subnet" "db_sub_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.14.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-db-sub-2a"
  }
}

resource "aws_subnet" "db_sub_c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.24.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-db-sub-2c"
  }
}

resource "aws_subnet" "redis_sub_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.15.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.tag}-redis-sub-2a"
  }
}

resource "aws_subnet" "redis_sub_c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.25.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.tag}-redis-sub-2c"
  }
}