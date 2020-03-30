data "aws_iam_role" "eks_cluster" {
  name = "${var.env}-${var.app_name}-eks-cluster-role"
}

data "aws_iam_role" "eks_node" {
  name = "${var.env}-${var.app_name}-eks-node-role"
}

resource "aws_eks_cluster" "cluster" {
  name = "${var.env}-${var.app_name}"
  role_arn = data.aws_iam_role.eks_cluster.arn
  version = var.k8s_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_iam_role_policy_attachment.eks_service",
  ]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "${var.env}-${var.app_name}-node-group"
  node_role_arn = data.aws_iam_role.eks_node.arn
  subnet_ids = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = "dev-broker-demo-akano"
    source_security_group_ids = [aws_security_group.eks_node_remote_access.id]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_worker_node",
    "aws_iam_role_policy_attachment.eks_cni",
    "aws_iam_role_policy_attachment.ecr_read",
  ]
}