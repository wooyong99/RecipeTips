# node group role
resource "aws_iam_role" "EKSNodeGroupRole" {
  name = "EKSNodeGroupRole"

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
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

tags = {
    tag-key = "recipe-ng-role"
  }
}


# policy attachmnet
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.EKSNodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.EKSNodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.EKSNodeGroupRole.name
}


# release version
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.recipe-cluster.version}/amazon-linux-2/recommended/release_version"
}


# node group
resource "aws_eks_node_group" "recipe-node-group" {
  cluster_name    = aws_eks_cluster.recipe-cluster.name
  node_group_name = "${var.tag}-node-group"
  version         = aws_eks_cluster.recipe-cluster.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.EKSNodeGroupRole.arn
  subnet_ids      = [aws_subnet.pub_sub_a.id, aws_subnet.pub_sub_c.id]

  remote_access {
    ec2_ssh_key   = aws_key_pair.recipe_key.key_name
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true" 
    "k8s.io/cluster-autoscaler/recipe-cluster" = "owned"
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

   ami_type       = "AL2_x86_64"
  instance_types = ["t3.large"]
  #capacity_type  = "ON_DEMAND"
  disk_size      = 20

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}