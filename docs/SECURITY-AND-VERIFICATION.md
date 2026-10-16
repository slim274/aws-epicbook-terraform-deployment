# Security, publication, and evidence boundaries

## Before uploading Terraform source to GitHub

- Never commit `terraform.tfstate`, `.terraform/`, `.tfvars` containing secrets, SSH private keys, `.env`, credentials, or plan files containing sensitive values.
- This report contains an example database password. **It has been deliberately omitted from this documentation.** If that password was ever real, rotate it in the database before publishing related work.
- Never hardcode RDS passwords into source, example README snippets, or Terraform variables with literal defaults.
- If the original project uses `tls_private_key`, keep state files strictly private because Terraform state can store private keys.
- Inspect terminal captures and AWS console screenshots for AWS account numbers, hostnames, personal details, tokens and passwords before publication. Cloud-console account/profile corners in selected screenshots have been softened.
- Limit EC2 SSH ingress to trusted IPs; permit DB port 3306 only from the application security group.

## Claims supported by the report

- An AWS EC2 + RDS architecture provisioned using Terraform.
- EpicBook served via Nginx on a Linux VM; browser evidence exists.
- Remote MySQL connection and table inspection; sample data insertion described.
- Troubleshooting of environment variables, Nginx, RDS subnet groups and SSH keys.

## Not independently established

- Ongoing production uptime, HTTPS, secret rotation, automated application deployment from `user_data`, CI/CD, end-to-end failover or sustained high-availability testing.

### Original source and contributor credit

The EpicBook application originated with [pravinmishraaws/theepicbook](https://github.com/pravinmishraaws/theepicbook). The cloud configuration and internship report are separate work.
