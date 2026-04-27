# Project Details

1. `aws_security_group.rds_security_group` — only port 3306 from the VPC CIDR (`10.0.0.0/16`); all egress.
2. `aws_db_parameter_group.my_mysql_parameter_group` — MySQL 8.0 family with strict `sql_mode`, 2 GB buffer pool, 1 GB log file, 256 MB `max_allowed_packet`.
3. `aws_db_subnet_group.my_db_subnet_group` — six subnets across AZs.
4. `aws_db_instance.my_rds_instance` — `db.t3.micro`, 20 GB, identifier `ms-dev`, password via `var.db_password` (supply via `terraform.tfvars` or `TF_VAR_db_password` — never commit).

