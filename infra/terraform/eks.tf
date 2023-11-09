# eks role
resource "aws_iam_role" "EKSClusterRole" {
  name = "EKSClusterRole"

 # Terraform's "jsonencode" function converts a
 # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

tags = {
    tag-key = "${var.tag}-role"
  }
}


# policy attachmnet
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.EKSClusterRole.name
}


# eks cluster
resource "aws_eks_cluster" "recipe-cluster" {
  name                  = var.cluster
  role_arn              = aws_iam_role.EKSClusterRole.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids          = [aws_subnet.pub_sub_a.id, aws_subnet.pub_sub_c.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.recipe-cluster.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.example.certificate_authority[0].data
# }