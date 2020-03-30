locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: ${var.env}-${var.app_name}
contexts:
- context:
    cluster: ${var.env}-${var.app_name}
    user: ${var.env}-${var.app_name}
  name: ${var.env}-${var.app_name}
current-context: aws
kind: Config
preferences: {}
users:
- name: ${var.env}-${var.app_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${local.cluster_name}"
KUBECONFIG

  eks_configmap = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "kubectl_config" {
  value = local.kubeconfig
}

output "eks_configmap" {
  value = local.eks_configmap
}