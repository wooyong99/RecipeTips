# db subnet
resource "aws_db_subnet_group" "db_subnet" {
  name       = "recipe-db-subnetgroup"
  subnet_ids = [aws_subnet.db_sub_a.id, aws_subnet.db_sub_c.id]

  tags = {
    Name = "${var.tag}-db-subnetgroup"
  }
}

# RDS
resource "aws_db_instance" "db" {
  identifier_prefix      = "cccr"
  allocated_storage      = 10 
  engine                 = "mariadb"
  engine_version         = "10.6.14"
  instance_class         = "db.t3.medium"
  db_name                = "cccr"
  username               = "admin"
  password               = "recipe1234"
  parameter_group_name   = "default.mariadb10.6"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "${var.tag}-db"
  }
}