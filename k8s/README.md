# Kubernetes Resources

This directory contains Kubernetes manifests for deploying HTTPBin application on EKS cluster.

---

## Resources Overview

### 00-namespace.yaml
- **Namespace**: `playson-dev`
- Isolated environment for HTTPBin deployment
- Labeled for easy identification and management

### 01-network-policy.yaml
- **NetworkPolicy** for pod-level network isolation
- Controls ingress/egress traffic to HTTPBin pods
- Allows traffic from ALB and within namespace

### 02-deployment.yaml
- **Deployment**: HTTPBin with 3 replicas
- **Pod Anti-Affinity**: `preferredDuringSchedulingIgnoredDuringExecution` for even distribution
- **Resource Limits**
- **Health Checks**: Liveness and readiness probes
- **Image**: `kennethreitz/httpbin:latest` from tech task

### 03-service.yaml
- **Service Type**: ClusterIP
- Target port 80

### 04-ingress.yaml
- **Ingress** with ALB annotations
- **Scheme**: Internal 
- **Target Type**: IP
- **DNS**: Managed by external-dns annotation
- **Health Check**: `/status/200`

---

## Deployment

### Prerequisites

1. EKS cluster is running (deployed via Terraform)
2. kubectl configured to access the cluster
3. AWS Load Balancer Controller installed in cluster

### Deploy All Resources

```bash
# Deploy in order
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-network-policy.yaml
kubectl apply -f 02-deployment.yaml
kubectl apply -f 03-service.yaml
kubectl apply -f 04-ingress.yaml
```

### Verify Deployment

```bash
kubectl get namespace playson-dev

# Check pods
kubectl get pods -n playson-dev -o wide

# Check ingress and ALB creation
kubectl get ingress -n playson-dev
kubectl describe ingress httpbin -n playson-dev
```
---

## Testing

### Port-Forward (Quick Test)

```bash
# Forward to service
kubectl port-forward -n playson-dev svc/httpbin 8080:80

# Test it!
curl http://localhost:8080/get
```

### Via Internal Domain (from within VPC)

```bash
# From bastion or using VPC
curl http://httpbin.playson-tka.int/get
curl http://httpbin.playson-tka.int/headers
curl http://httpbin.playson-tka.int/status/200
```
---

## Production Readiness Checklist

For production deployment, consider:

- [ ] Add HPA for automatic scaling
- [ ] Configure PDB for high availability
- [ ] Implement resource quotas per namespace
- [ ] Set up monitoring with Prometheus/Grafana
- [ ] Configure alerts for critical metrics
- [ ] Use specific image tags instead of `latest`
- [ ] Implement GitOps workflow (ArgoCD/Flux)
- [ ] Add backup strategy for persistent data
- [ ] Configure pod security policies/standards
- [ ] Set up logging aggregation (ELK/Loki/VMLogs)
- [ ] Implement secrets management (AWS Secrets, Vault)
- [ ] Add admission controllers for policy enforcement

---

## Related Documentation

- [Main README](../README.md) - Project overview
- [Terraform README](../terraform/README.md) - Infrastructure setup

---

## Notes

- This configuration is optimized for **development** environment
- Uses `kennethreitz/httpbin:latest` - consider pinning specific version for production
- Resource limits are set for t3.micro nodes - adjust for production workloads
- Network policies can be extended for more granular control