# Terraform Infrastructure

This directory contains Terraform code for provisioning AWS infrastructure required for the HTTPBin deployment on EKS.

---

## AWS Resources Created

### Network Infrastructure (`01-network.tf`)
- **VPC** with CIDR `10.0.0.0/16`
- **3 Public Subnets** (10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24) across 3 AZs
- **3 Private Subnets** (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24) across 3 AZs
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for private subnet outbound traffic
- **Route Tables** with proper routing configuration
- **Subnet Tags** for AWS Load Balancer Controller discovery

### DNS (`02-route53.tf`)
- **Private Hosted Zone**: `playson-tka.int`
- Associated with VPC for internal DNS resolution

### EKS Cluster (`03-eks.tf`)
- **EKS Control Plane** (Kubernetes 1.31)
- **Managed Node Group** with 3 t3.micro instances
- **EKS Add-ons**: VPC-CNI, CoreDNS, kube-proxy, Pod Identity Agent
- **AWS Load Balancer Controller** via Helm
- **Node Security Group** rules for ALB communication

### IAM & Pod Identity (`04-pod-identity.tf`)
- **IAM Role** for AWS Load Balancer Controller
- **Pod Identity Association** for secure AWS API access
- **IAM Policies** for ALB management

---

## Prerequisites

### 1. S3 Bucket for Remote State

Before running Terraform, you need to create an S3 bucket for storing Terraform state remotely.

**Important**: You must create your own S3 bucket and configure it in `config.s3.tfbackend`.

### 2. Configure Backend

Edit `config.s3.tfbackend` with your values:

```hcl
bucket  = "your-terraform-state-bucket"      # Your S3 bucket name
key     = "playson-tka/terraform.tfstate"    # Path to state file
region  = "us-east-1"                        # AWS region
profile = "profile_development_tka"          # Your AWS profile
encrypt = true
```

### 3. Configure Variables

Edit `terraform.tfvars` with your values:

```hcl
name               = "playson-tka"
env                = "development"
region             = "us-east-1"
cidr               = "10.0.0.0/16"
private_subnets    = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
public_subnets     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
single_nat_gateway = true
```

---

## Deployment

### Initialize Terraform

```bash
cd terraform/

# Initialize with backend configuration
terraform init -backend-config=config.s3.tfbackend
```

### Plan and Apply

```bash

terraform plan
terraform apply

```

### Terraform State List

```bash
terraform state list
data.aws_caller_identity.current
aws_eks_pod_identity_association.alb_controller
aws_iam_policy.alb_controller
aws_iam_role.alb_controller
aws_iam_role_policy_attachment.alb_controller
aws_security_group.alb
module.eks.data.aws_caller_identity.current[0]
module.eks.data.aws_eks_addon_version.this["coredns"]
module.eks.data.aws_eks_addon_version.this["eks-pod-identity-agent"]
module.eks.data.aws_eks_addon_version.this["kube-proxy"]
module.eks.data.aws_eks_addon_version.this["vpc-cni"]
module.eks.data.aws_iam_policy_document.assume_role_policy[0]
module.eks.data.aws_iam_session_context.current[0]
module.eks.data.aws_partition.current[0]
module.eks.data.tls_certificate.this[0]
module.eks.aws_cloudwatch_log_group.this[0]
module.eks.aws_eks_access_entry.this["main_user"]
module.eks.aws_eks_access_policy_association.this["main_user_admin"]
module.eks.aws_eks_addon.before_compute["eks-pod-identity-agent"]
module.eks.aws_eks_addon.before_compute["vpc-cni"]
module.eks.aws_eks_addon.this["coredns"]
module.eks.aws_eks_addon.this["kube-proxy"]
module.eks.aws_eks_cluster.this[0]
module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
module.eks.aws_iam_policy.cluster_encryption[0]
module.eks.aws_iam_role.this[0]
module.eks.aws_iam_role_policy_attachment.cluster_encryption[0]
module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]
module.eks.aws_security_group.cluster[0]
module.eks.aws_security_group.node[0]
module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]
module.eks.aws_security_group_rule.node["alb_to_nodes"]
module.eks.aws_security_group_rule.node["egress_all"]
module.eks.aws_security_group_rule.node["ingress_cluster_443"]
module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"]
module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"]
module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"]
module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]
module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"]
module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]
module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]
module.eks.time_sleep.this[0]
module.vpc.aws_default_network_acl.this[0]
module.vpc.aws_default_route_table.default[0]
module.vpc.aws_default_security_group.this[0]
module.vpc.aws_eip.nat[0]
module.vpc.aws_internet_gateway.this[0]
module.vpc.aws_nat_gateway.this[0]
module.vpc.aws_route.private_nat_gateway[0]
module.vpc.aws_route.public_internet_gateway[0]
module.vpc.aws_route_table.private[0]
module.vpc.aws_route_table.public[0]
module.vpc.aws_route_table_association.private[0]
module.vpc.aws_route_table_association.private[1]
module.vpc.aws_route_table_association.private[2]
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]
module.vpc.aws_route_table_association.public[2]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_subnet.private[2]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_subnet.public[2]
module.vpc.aws_vpc.this[0]
module.zone.aws_route53_zone.this[0]
module.eks.module.eks_managed_node_group["httbin"].data.aws_iam_policy_document.assume_role_policy[0]
module.eks.module.eks_managed_node_group["httbin"].data.aws_ssm_parameter.ami[0]
module.eks.module.eks_managed_node_group["httbin"].aws_eks_node_group.this[0]
module.eks.module.eks_managed_node_group["httbin"].aws_iam_role.this[0]
module.eks.module.eks_managed_node_group["httbin"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]
module.eks.module.eks_managed_node_group["httbin"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]
module.eks.module.eks_managed_node_group["httbin"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
module.eks.module.eks_managed_node_group["httbin"].aws_launch_template.this[0]
module.eks.module.kms.data.aws_caller_identity.current[0]
module.eks.module.kms.data.aws_iam_policy_document.this[0]
module.eks.module.kms.data.aws_partition.current[0]
module.eks.module.kms.aws_kms_alias.this["cluster"]
module.eks.module.kms.aws_kms_key.this[0]
module.eks.module.eks_managed_node_group["httbin"].module.user_data.null_resource.validate_cluster_service_cidr
```
## Important Notes

### Cost Considerations

- **t3.micro instances**: ~$22.5/month
- **NAT Gateway**: ~$32/month
- **EKS Control Plane**: ~$73/month
- **ALB**: ~$16/month
- **Total estimated**: ~$143/month

### Security

- Worker nodes are in **private subnets** 
- ALB is **internal-only** 
- IAM roles follow **principle of least privilege**
- Security Groups have **minimal required rules**

---

## Potential Improvements

Potential Improvements
This is a demonstration environment. For production use, consider the following improvements:

Before using this in production:

- [ ] Enable DynamoDB state locking
- [ ] Separate VPC into shared Terraform state
- [ ] Separate Route53 into shared Terraform state
- [ ] Implement multi-environment structure
- [ ] Add terraform-docs for documentation
- [ ] Configure tflint with AWS ruleset
- [ ] Set up pre-commit hooks
- [ ] Implement CI/CD pipeline
- [ ] Add security scanning (tfsec/Checkov)
- [ ] Configure cost monitoring (Infracost)
- [ ] Implement tagging strategy
- [ ] Set up monitoring and alerting
- [ ] Document runbooks for operations
- [ ] Plan disaster recovery procedures

## Next Steps

After Terraform deployment completes:

1.  Configure kubectl (see Post-Deployment section)
2.  Deploy Kubernetes resources from `k8s/` directory
3.  Verify HTTPBin deployment 
4.  Test endpoints using provided test script and using bastionhost or VPN

For Kubernetes deployment instructions, see [`../k8s/README.md`](../k8s/README.md)

