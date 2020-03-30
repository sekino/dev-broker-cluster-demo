resource "aws_iam_policy" "eks_alb_ingress" {
  name = "ALBIngressControllerPolicy"
  policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "acm:GetCertificate"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:DeleteSecurityGroup",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVpcs",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifyNetworkInterfaceAttribute",
            "ec2:RevokeSecurityGroupIngress"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeListenerCertificates",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeTags",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:RemoveTags",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:SetWebACL"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "iam:CreateServiceLinkedRole",
            "iam:GetServerCertificate",
            "iam:ListServerCertificates"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "cognito-idp:DescribeUserPoolClient"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "waf-regional:GetWebACLForResource",
            "waf-regional:GetWebACL",
            "waf-regional:AssociateWebACL",
            "waf-regional:DisassociateWebACL"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "tag:GetResources",
            "tag:TagResources"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "waf:GetWebACL"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "shield:DescribeProtection",
            "shield:GetSubscriptionState",
            "shield:DeleteProtection",
            "shield:CreateProtection",
            "shield:DescribeSubscription",
            "shield:ListProtections"
         ],
         "Resource":"*"
      }
   ]
}
POLICY
}

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name = "${var.env}-${var.app_name}-eks-alb-ingress-controller"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::757833611845:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/5A16ECC06C9530C184A3945718D7E87B"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-northeast-1.amazonaws.com/id/5A16ECC06C9530C184A3945718D7E87B:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_alb_ingress" {
  policy_arn = aws_iam_policy.eks_alb_ingress.arn
  role       = aws_iam_role.eks_alb_ingress_controller.name
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.env}-${var.app_name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS node
resource "aws_iam_role" "eks_node" {
  name = "${var.env}-${var.app_name}-eks-node-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = "EKSClusterAutoscalerPolicy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler" {
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
  role       = aws_iam_role.eks_node.name
}
