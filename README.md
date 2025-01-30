# Multi-Region Notary Server Deployment

This repository contains Infrastructure as Code (IaC) that deploys a **Notary service** across multiple AWS regions. The Notary service runs within AWS Nitro Enclaves to support attestation, and uses **Amazon Route 53** geolocation-based routing to direct users to the nearest Notary instance.

> **WARNING: This is a demo implementation and is \*not\* production-ready. Critical security and operational components are missing. Use at your own risk.**

------

## Overview

- **Regions**: Deploys to `us-east-1` and `eu-west-1` (can be extended)
- **Routing**: Amazon Route 53 geolocation-based routing
- **Load Balancer**: Network Load Balancer (NLB) with TCP listeners on port `7047`
- **Health Checks**: HTTPS health checks on `/healthcheck`
- **Nitro Enclave**: Automated enclave environment setup for attestation

------

## Prerequisites

1. **AWS CLI**
   - Installed locally and configured with credentials/permissions
   - Must have permissions to create and manage VPCs, subnets, EC2 instances, IAM roles/policies, Route 53 records, etc.
2. **Terraform (v1.3+)**
   - Required for Infrastructure as Code.
3. **Existing SSH Key Pairs (per region)**
   - For development and debugging, ensure you have an SSH key pair in each target region.
   - **Production Note**: Typically, you'd have Terraform generate and manage these keys securely, then destroy them to prevent SSH access in production.
4. **Registered Domain in Route 53**
   - Necessary for setting up geolocation-based DNS and domain routing.
5. **Docker (Optional)**
   - Required only if you need to build or customize the Notary Docker image locally.
   - In a fully automated pipeline, you might rely on an existing CI/CD system or a container registry.

------

## Deployment Steps

```bash
# Clone repository
git clone https://github.com/sampka/notary-deployment.git
cd notary-deployment

# Initialize Terraform
terraform init

# Deploy infrastructure
terraform apply -var="domain_name=your-domain.com" -var="key_name=your-keypair"
```

------

- - ## Observability & Health Checks

    ### Health Check Endpoint

    - The Notary service exposes a `GET /healthcheck` endpoint. If the service is running, it returns a **200 OK**.
    - Amazon Route 53 polls the NLBs in each region, and the NLBs in turn poll the servers themselves.
      - If a region becomes unhealthy, Route 53 automatically stops routing traffic there.
      - If a specific server fails health checks, the NLB will remove it from rotation.

    ### Metrics & Monitoring

    - This deployment does not include a dedicated monitoring or alerting solution out of the box.

    - Production Tip

      : Proper monitoring involves more than collecting raw metrics; it includes alert thresholds, actionable incident workflows, and potential automated remediation. Some suggestions:

      1. **Collect Metrics**: Use Amazon CloudWatch or Prometheus to track CPU, memory, network usage, and custom application metrics.
      2. **Set Alerts**: Define meaningful thresholds for high CPU/memory/error rates, and integrate alerting via CloudWatch Alarms, PagerDuty, or Opsgenie.
      3. **Analyze & Visualize**: Add dashboards (e.g., Grafana) for real-time insights into system performance and trends.
      4. **Automate Responses**: Where feasible, configure auto-scaling or self-healing to reduce the need for manual interventions.

    ------

    ## Assumptions About Existing Systems

    This demo implementation assumes your organization already has these **critical systems** in place. If you’re starting from scratch, each may represent multiple weeks of work:

    1. **Certificate Lifecycle Management**
       - Existing root CA infrastructure
       - Automated issuance/renewal (e.g., AWS Certificate Manager or Vault PKI, lets encrypt)
       - Certificate revocation workflows
    2. **Resource Tagging Policies**
       - AWS tag enforcement (e.g., “Environment”, “Owner”)
       - Cost allocation reporting
       - Automation guardrails based on tags
    3. **Environment Configuration Management**
       - Tools like Helm, Terragrunt, or similar for environment configurations
       - Pipelines for environment promotion (e.g., dev → staging → prod)
       - Versioned configuration store
    4. **Cryptographic Key Management**
       - Key rotation schedules
       - Audit logging
       - Centralized secrets storage (e.g., AWS Secrets Manager or Vault)
       - Ephemeral credentials and dynamic secret generation
    5. **Source Control Access Controls**
       - GitHub machine account management
       - Fine-grained repository permissions
       - CI/CD bot credentialing

------

## Roadmap

### Immediate Requirements (P0)

- [ ] Implement ACM certificate automation
- [ ] Encrypt SSH keys with KMS
- [ ] Finalize secure Security Group rules
- [ ] Configure remote Terraform state (S3 + DynamoDB)
- [ ] Design & implement IAM roles with permission boundaries
- [ ] Automate AWS Config
- [ ]  Formalize VPC network design
- [ ] Modularize Terraform for reusability
- [ ] lock down access to production ec2's

### Short-Term Improvements (P1)

- [ ] Add VPC peering configuration
- [ ] Implement monitoring and automation
- [ ] Docker image versioning in a container registry
- [ ] AWS Organizational Account Design
- [ ] Centralized Logging for all accounts

### Long-Term Goals (P2)

- [ ] End-to-end CI/CD pipeline
- [ ] Cross-account deployment support
- [ ] Automated attestation verification
- [ ] Disaster recovery workflows



