# bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "recipe-bastion-sg"
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "allow_jenkins"
  description = "Allow jenkins inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "jenkins from VPC"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "recipe-jenkins-sg"
  }
}

# DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "allow_db"
  description = "Allow db inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "db from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "recipe-db-sg"
  }
}

# ingress Security Group
resource "aws_security_group" "ingress_sg" {
  name        = "ingress_sg"
  description = "Ingress Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "recipe-ingress-sg"
  }
}


# admin ingress Security Group
resource "aws_security_group" "monitoring_ingress_sg" {
  name        = "monitoring_ingress_sg"
  description = "Monitoring Ingress Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-ingress-sg"
  }
}


# cluster security group
resource "aws_security_group" "cluster_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "cluster-sg"
  description = "cluster security group"

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

  tags = { 
    Name = "recipe-cluster-sg" 
    }
}


# app
resource "aws_security_group_rule" "cluster_front_rule" {
  description              = "alb-front"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 80
  type                     = "ingress"
}


resource "aws_security_group_rule" "cluster_member_rule" {
  description              = "alb-back"
  from_port                = 8081
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.ingress_sg.id  # 또 다른 보안 그룹을 참조
  to_port                  = 8083
  type                     = "ingress"
}

# app node port
resource "aws_security_group_rule" "cluster_app_nodeport_rule" {
  description              = "alb-node-port"
  from_port                = 30000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 32767
  type                     = "ingress"
}

# monitoring
resource "aws_security_group_rule" "cluster_elasticsearch_rule" {
  description              = "alb-elasticsearch"
  from_port                = 9200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 9200
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_kibana_rule" {
  description              = "alb-kibana"
  from_port                = 5601
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 5601
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_grafana_rule" {
  description              = "alb-grafana"
  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 3000
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_prometheus_rule" {
  description              = "alb-prometheus"
  from_port                = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 9090
  type                     = "ingress"
}

# argo
resource "aws_security_group_rule" "cluster_argo_rule" {
  description              = "alb-argo"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 8080
  type                     = "ingress"
}

# monitoring node port
resource "aws_security_group_rule" "cluster_mon_nodeport_rule" {
  description              = "alb-node-port"
  from_port                = 30000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.monitoring_ingress_sg.id  # 다른 보안 그룹을 참조
  to_port                  = 32767
  type                     = "ingress"
}
