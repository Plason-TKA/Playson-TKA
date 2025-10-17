# HTTPBin Deployment on AWS EKS

## Overview

This repository contains a production-ready deployment of HTTPBin application on AWS EKS infrastructure, implemented according to all technical requirements specified in the assignment.

---

## Technical Requirements - Implementation Status

✅ **Infrastructure as Code** - Terraform for all AWS resources  
✅ **Kubernetes Deployment** - HTTPBin with high availability configuration  
✅ **Even Distribution** - Pods distributed across all cluster nodes using pod anti-affinity  
✅ **Internal Load Balancer** - ALB created automatically via Kubernetes Ingress  
✅ **Private DNS** - Route53 hosted zone for internal access (playson-tka.int)
✅ **Security Best Practices** - Proper IAM roles, Security Groups, and network isolation  
✅ **Resource Management** - CPU/Memory requests and limits configured  
✅ **Health Checks** - Liveness and readiness probes implemented  

---

## Repository Structure

```
.
├── README.md                    
├── .gitignore                   
│
├── k8s/                         
│   ├── 00-namespace.yaml
│   ├── 01-network-policy.yaml
│   ├── 02-deployment.yaml
│   ├── 03-service.yaml
│   └── 04-ingress.yaml
│
└── terraform/                   # Infrastructure as Code
    ├── templates/               # Template files
    ├── 00-initial.tf            # Provider and backend configuration
    ├── 01-network.tf            # VPC and networking
    ├── 02-route53.tf            # Private hosted zone
    ├── 03-eks.tf                # EKS cluster
    ├── 04-pod-identity.tf       # Pod identity for ALB controller
    ├── config.s3.tfbackend      # S3 backend configuration
    ├── terraform.tfvars         # Variables (gitignored)
    ├── variables.tf             # Variable definitions
    └── versions.tf              # Terraform and provider versions
```

---

## Infrastructure Components

### AWS Account Setup

The infrastructure is deployed on a dedicated AWS account with the following components:

- **VPC** with public and private subnets, NAT etc
- **EKS Cluster** with managed node group
- **AWS Load Balancer Controller** for automatic ALB provisioning
- **Route53 Private Hosted Zone** for internal DNS resolution
- **Security Groups** and IAM roles with least privilege principles

📖 **Detailed infrastructure documentation:** [`terraform/README.md`](terraform/README.md)

### Key Infrastructure Features

- **High Availability**: Resources distributed across 3 AZs (us-east-1a, us-east-1b, us-east-1c)
- **Cost Optimization**: t3.micro instances for dev environment
- **Security**: Private subnets for worker nodes, internal-only ALB
- **Automation**: Full Infrastructure as Code with Terraform

---

## Kubernetes Deployment

The application layer is deployed using Kubernetes manifests with the following components:

- **Namespace**: `playson-dev`
- **Deployment**: HTTPBin with 3 replicas
- **Service**: ClusterIP type for internal communication
- **Ingress**: Automatically creates internal ALB 

📖 **Detailed Kubernetes documentation:** [`k8s/README.md`](k8s/README.md)

### Key Kubernetes Features

- **Even Pod Distribution**: `podAntiAffinity` with `requiredDuringSchedulingIgnoredDuringExecution` ensures 1 pod per node
- **Resource Management**: cpu and mem limits configured
- **Health Monitoring**: Liveness and readiness probes on `/status/200` endpoint

---

## Architecture Overview

### Network Flow

1. **DNS Resolution**: `httpbin.playson-tka.int` resolves to internal ALB
2. **Load Balancing**: ALB distributes traffic to healthy pods across all nodes
3. **Pod Distribution**: Anti-affinity ensures each pod runs on a different node
4. **Health Checks**: ALB only routes to pods passing health checks

### Private Hosted Zone

**Domain**: `playson-tka.int`  
**Record**: `httpbin.playson-tka.int` → Internal ALB DNS

This private hosted zone is used for testing and accessing the HTTPBin service within the VPC. The domain is only resolvable within the VPC and is not accessible from the internet.

---

## Testing Results

### Test Script

A simple bash script was created to test various HTTPBin endpoints:

**Location**: `scripts/test-httpbin.sh`

**Usage**:
```bash
chmod +x scripts/test-httpbin.sh
./scripts/test-httpbin.sh
```

### Test Results

```
Testing HTTPBin at: httpbin.playson-tka.int
================================
GET /get -> 200
GET /get?key=value -> 200
GET /headers -> 200
GET /user-agent -> 200
GET /status/200 -> 200
GET /status/201 -> 201
GET /status/404 -> 404
GET /status/500 -> 500
GET /ip -> 200
GET /delay/2 -> 200
GET /uuid -> 200
GET /base64/SFRUUEJpbg== -> 200
GET /html -> 200
GET /json -> 200
GET /robots.txt -> 200
GET /cache -> 200
GET /response-headers?key=value -> 200
================================
Done!
```

✅ **All endpoints returned expected status codes**

### Sample curl Output

```bash
curl -I http://httbin.playson-tka.int
HTTP/1.1 200 OK
Date: Fri, 17 Oct 2025 16:52:51 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 9593
Connection: keep-alive
Server: gunicorn/19.9.0
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

### Pod Distribution Verification

```bash
$ kubectl get pods -n playson-dev -o wide

NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE                         NOMINATED NODE   READINESS GATES
httpbin-5887d5c4b9-8qqzr   1/1     Running   0          21h   10.0.3.176   ip-10-0-3-163.ec2.internal   <none>           <none>
httpbin-5887d5c4b9-fsq9t   1/1     Running   0          21h   10.0.2.18    ip-10-0-2-88.ec2.internal    <none>           <none>
httpbin-5887d5c4b9-p7bxn   1/1     Running   0          21h   10.0.1.128   ip-10-0-1-14.ec2.internal    <none>           <none>
```

✅ **Pods are distributed across 3 different nodes as required**

### Deployment Status

```bash
$ kubectl describe deployment httpbin -n playson-dev

Name:                   httpbin
Namespace:              playson-dev
CreationTimestamp:      Thu, 16 Oct 2025 22:15:26 +0300
Labels:                 app=httpbin
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=httpbin
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=httpbin
  Containers:
   httpbin:
    Image:      kennethreitz/httpbin:latest
    Port:       80/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        50m
      memory:     64Mi
    Liveness:     http-get http://:http/status/200 delay=10s timeout=3s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/status/200 delay=5s timeout=3s period=5s #success=1 #failure=2
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   httpbin-5887d5c4b9 (3/3 replicas created)
Events:          <none>
```

✅ **All 3 replicas are running and healthy**

### Ingress Status

```bash
$ kubectl describe ingress httpbin -n playson-dev

Name:             httpbin
Labels:           <none>
Namespace:        playson-dev
Address:          internal-k8s-playsond-httpbin-6954cbf006-1070227179.us-east-1.elb.amazonaws.com
Ingress Class:    alb
Default backend:  <default>
Rules:
  Host                    Path  Backends
  ----                    ----  --------
  httbin.playson-tka.int
                          /   httpbin:80 (10.0.1.128:80,10.0.2.18:80,10.0.3.176:80)
Annotations:              alb.ingress.kubernetes.io/healthcheck-interval-seconds: 30
                          alb.ingress.kubernetes.io/healthcheck-path: /status/200
                          alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
                          alb.ingress.kubernetes.io/healthcheck-timeout-seconds: 5
                          alb.ingress.kubernetes.io/healthy-threshold-count: 2
                          alb.ingress.kubernetes.io/scheme: internal
                          alb.ingress.kubernetes.io/security-groups: sg-054801b9ffa7920b8
                          alb.ingress.kubernetes.io/tags: Environment=development,Application=httpbin,ManagedBy=kubernetes
                          alb.ingress.kubernetes.io/target-type: ip
                          alb.ingress.kubernetes.io/unhealthy-threshold-count: 3
Events:
  Type     Reason                  Age                 From     Message
  ----     ------                  ----                ----     -------
  Normal   SuccessfullyReconciled  31m (x2 over 21h)   ingress  Successfully reconciled
```

✅ **Internal ALB created successfully with 3 healthy targets**

## Documentation

- [Terraform Infrastructure](terraform/README.md) - Detailed infrastructure setup and configuration
- [Kubernetes Deployment](k8s/README.md) - Application deployment and management

---

## Key Design Decisions

1. **Separation of Concerns**: Infrastructure (Terraform) and application (Kubernetes) are managed separately for better maintainability and GitOps readiness

2. **Pod Anti-Affinity**: Used `preferredDuringSchedulingIgnoredDuringExecution` to guarantee even distribution across nodes, ensuring high availability

3. **Internal ALB**: Load balancer is internal-only for security, accessible only within VPC

4. **Private DNS**: Route53 private hosted zone provides clean, memorable URLs for internal services

5. **Cost Optimization**: t3.micro instances used for dev while maintaining production-like architecture

6. **Security First**: Principle of least privilege applied to all IAM roles and Security Groups

## Notes

This is a demonstration environment optimized for cost and quick deployment. For production use, consider:

- Larger instance types (t3.small or higher)
- Multi-AZ NAT Gateways for redundancy
- Monitoring and alerting stack (Prometheus, Grafana etc)
- Backup and disaster recovery strategy
- CI/CD pipeline integration
- Enhanced security measures (Network Policies, Pod Security Standards)
- Resource optimization via quotas and linits