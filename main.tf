provider "aws" {
  region = var.aws_region
}

# Create a new security group for the RDS instance
resource "aws_security_group" "rds_security_group" {
  name        = "RDS-security-group"
  description = "Security group for RDS instance restricted to specific VPC"
  vpc_id      = var.vpc_id

  # Ingress rule to allow MySQL access (port 3306) only from the specified VPC CIDR block
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all egress (outbound) traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# Create a new RDS parameter group
resource "aws_db_parameter_group" "my_mysql_parameter_group" {
  name        = "my-mysql-parameter-group"
  family      = "mysql8.0"
  description = "My custom parameter group for MySQL"

  # Dynamic parameters (apply immediately)
  parameter {
    name         = "sql_mode"
    value        = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION"
    apply_method = "immediate"
  }

  parameter {
    name         = "innodb_buffer_pool_size"
    value        = "2147483648"  # 2G in bytes
    apply_method = "immediate"
  }

  parameter {
    name         = "innodb_log_buffer_size"
    value        = "268435456"   # 256M in bytes
    apply_method = "immediate"
  }

  parameter {
    name         = "max_allowed_packet"
    value        = "268435456"   # 256M in bytes
    apply_method = "immediate"
  }

  # Static parameter (requires reboot)
  parameter {
    name         = "innodb_log_file_size"
    value        = "1073741824"  # 1G in bytes
    apply_method = "pending-reboot"
  }
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

# Create the RDS instance
resource "aws_db_instance" "my_rds_instance" {
  identifier              = "ms-dev"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"   # Adjust instance class as necessary
  allocated_storage       = 20              # Adjust storage size as necessary
  parameter_group_name    = aws_db_parameter_group.my_mysql_parameter_group.name
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  username                = var.db_username
  password                = var.db_password   # pass via terraform.tfvars or TF_VAR_db_password; never commit plaintext

  skip_final_snapshot     = true  # Set to false for production to avoid data loss
  publicly_accessible     = false
  tags = {
    Name = "Stage Test"
  }
}
