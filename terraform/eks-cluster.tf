resource "aws_eks_cluster" "cloudflow_cluster" {
  name = "cloudflow-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }

  depends_on = [ 
     aws_iam_role_policy_attachment.eks_policy_attachment
   ]
}


resource "aws_iam_role" "eks_role" {
  name = "eksRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}