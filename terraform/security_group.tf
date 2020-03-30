locals {
  cluster_name = "${var.env}-${var.app_name}"
}

locals {
  eks_shared_tag = map("kubernetes.io/cluster/${local.cluster_name}", "shared")
  eks_owned_tag = map("kubernetes.io/cluster/${local.cluster_name}", "owned")
}

resource "aws_security_group" "eks_cluster" {
  name = "${var.env}-${var.app_name}-eks-cluster"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.app_name}-eks-cluster"
    Environment = var.env
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "eks_node_remote_access" {
  name = "${var.env}-${var.app_name}-eks-node"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.app_name}-eks-node"
    Environment = var.env
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}