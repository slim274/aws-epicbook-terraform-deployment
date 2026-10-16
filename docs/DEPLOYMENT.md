# Architecture and deployment

## AWS resources described in the Week 10 report

Terraform provisioned a custom **VPC**, public/private subnets, an **Internet Gateway**, a public route table, **EC2 and RDS security groups**, an EC2 key pair, **Ubuntu 22.04 EC2** in the public subnet and **Amazon RDS MySQL** in private database subnets. The Word report records a failed RDS creation with only one subnet; the configuration was expanded to database subnets in different Availability Zones.

The web instance hosted the **EpicBook Node.js/Express monolith**, with **Nginx** routing inbound HTTP traffic to the application process. The application reached MySQL through the RDS endpoint; RDS was not described as internet-facing.

## Implementation overview (sanitized)

1. Review Terraform source, then run `terraform fmt -check`, `terraform init` and `terraform validate`.
2. Inspect `terraform plan` before deploying with `terraform apply`. The internship notes also used `terraform apply -auto-approve`; that bypasses the interactive approval step, so use it only when intentionally appropriate.
3. Connect to the instance using an SSH **private key stored outside Git**.
4. Install the runtime, Nginx, Git and a MySQL client; clone the original EpicBook application and install its dependencies.
5. Configure database connectivity through environment variables (see examples below), without publishing a real `.env` file.
6. Configure Nginx to reverse proxy browser traffic to the Node.js service. Verify with `sudo nginx -t` and a service reload/restart.
7. Start the Node.js application and verify the bookstore and MySQL connectivity.

### Environment variable names (no credentials)

```dotenv
DB_HOST=<your-rds-endpoint>
DB_USER=<database-user>
DB_PASSWORD=<provided-securely-at-runtime>
DB_NAME=epicbookdb
```

The report describes querying MySQL tables such as `Author`, `Book`, `Cart`, `Cartbook`, and `Checkout`, and inserting sample author/book data. These are evidence of an application/data connectivity test, **not a recommendation to embed production credentials or data in version control**.

## Repeatability note

This documentation reflects an actual historical deployment. It is **not a standalone runnable Terraform module**: provide the original reviewed `.tf` files and verify provider versions, resource names, SSH approach, database variables and application setup before attempting a new deployment.
