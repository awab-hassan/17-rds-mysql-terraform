# Project # 17: RDS MYSQL Deployment using terraform

Terraform configuration that provisions a MySQL 8.0 RDS instance inside an existing VPC, with a custom parameter group, a dedicated DB subnet group, and a security group that restricts port 3306 access to the VPC CIDR only.

A secure, private MySQL 8.0 RDS database locked inside an existing AWS VPC. It deploys the instance across a dedicated DB subnet group for high availability and applies a custom parameter group tuned for optimal application performance. To enforce strict access control, it configures a Security Group that only allows inbound connections on port 3306 originating from the VPC's internal network.

Intended as a dev/staging template. See the Notes section before using in production.

## What It Provisions

- **Security group** — allows inbound MySQL (port 3306) from the VPC CIDR block only. No public exposure.
- **DB subnet group** — places the instance across the provided subnet IDs.
- **Custom parameter group** (MySQL 8.0) — tuned for application workloads:

  | Parameter | Value | Apply method |
  |---|---|---|
  | `sql_mode` | `STRICT_TRANS_TABLES, NO_ENGINE_SUBSTITUTION, NO_UNSIGNED_SUBTRACTION` | immediate |
  | `innodb_buffer_pool_size` | 2 GB | immediate |
  | `innodb_log_buffer_size` | 256 MB | immediate |
  | `max_allowed_packet` | 256 MB | immediate |
  | `innodb_log_file_size` | 1 GB | pending-reboot |

- **RDS instance** — MySQL 8.0, `db.t3.micro`, 20 GB storage, `publicly_accessible = false`, VPC-internal only.

## Stack

Terraform 1.x · AWS RDS (MySQL 8.0) · VPC · Security Groups

## Required Variables

| Variable | Description |
|---|---|
| `aws_region` | AWS region to deploy into |
| `vpc_id` | ID of the existing VPC |
| `vpc_cidr_block` | VPC CIDR block allowed to reach port 3306 |
| `subnet_ids` | List of subnet IDs for the DB subnet group |
| `db_username` | Master database username |
| `db_password` | Master database password |

Pass credentials via `terraform.tfvars` or the `TF_VAR_db_password` environment variable. Never commit plaintext credentials.

## Repository Layout

```
rds-mysql-terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- `skip_final_snapshot = true` — safe for dev/staging. Set to `false` in production to prevent data loss on `terraform destroy`.
- `allocated_storage = 20 GB` and `db.t3.micro` are suitable for development. Resize before promoting to production.
- `innodb_log_file_size` requires a reboot to apply (`pending-reboot`). Plan for a maintenance window when changing this parameter.
- The egress rule allows all outbound traffic. Restrict if your security policy requires it.
