resource "aws_ecr_repository" "ecr-front" {
  name                 = "ecr-front"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "recipe-front"
  }
}


resource "aws_ecr_repository" "ecr-member" {
  name                 = "ecr-member"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "recipe-member"
  }
}


resource "aws_ecr_repository" "ecr-notice" {
  name                 = "ecr-notice"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "recipe-notice"
  }
}


resource "aws_ecr_repository" "ecr-recommend" {
  name                 = "ecr-recommend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "recipe-recommend"
  }
}