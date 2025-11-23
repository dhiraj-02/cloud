resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-rds"
  engine                  = "mysql"
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = false
}
