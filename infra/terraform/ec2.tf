# key pair
resource "tls_private_key" "recipe_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "recipe_key" {
  key_name   = "recipe_key"
  public_key = tls_private_key.recipe_keypair.public_key_openssh
}


resource "local_file" "key_local" {
  filename        = "recipe_key.pem"
  content         = tls_private_key.recipe_keypair.private_key_pem
  file_permission = "0400"
}


# image
data "aws_ami" "amazon-linux-2023" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}


# db_bastion
resource "aws_instance" "db_bastion" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.recipe_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.pub_sub_a.id

  tags = {
    Name = "${var.tag}-db-bastion"
  }
}


# mgmt_bastion
resource "aws_instance" "mgmt_bastion" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.recipe_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.pub_sub_c.id

  tags = {
    Name = "${var.tag}-mgmt-bastion"
  }
}


# jenkins_server
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.recipe_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.jenkins_sub_c.id
  user_data_replace_on_change = true

  # jenkins 설치 및 설정
  user_data = file("jenkins.tftpl")

  tags = {
    Name = "${var.tag}-jenkins"
  }
}


# db mgmt
resource "aws_instance" "db_mgmt" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.recipe_key.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_id              = aws_subnet.mgmt_sub_a.id
  user_data_replace_on_change = true

  # mariadb 설치
  user_data = file("rds.tftpl")

  tags = {
    Name = "${var.tag}-db-mgmt"
  }
}


# eks mgmt
resource "aws_instance" "eks_mgmt" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.recipe_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.mgmt_sub_c.id

  tags = {
    Name = "${var.tag}-eks-mgmt"
  }
}
