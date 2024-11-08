provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
data "aws_vpc" "default" {
  default = true
}
resource "random_string" "phil-db-password" {
  length  = 32
  upper   = true
  numeric  = true
  special = false
}
resource "aws_security_group" "phil" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "phil"
  description = "Allow all inbound for Postgres"
ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "default" {
  db_name                = "phil"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.15"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.phil.id]
  username               = "vid"
  password               = "random_string.phil-db-password.result"
}