resource "aws_security_group" "msk_sg" {
  name   = "${var.project_name}-msk-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Internal VPC traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "main" {
  cluster_name           = var.msk_cluster_name
  kafka_version          = "3.6.0"
  number_of_broker_nodes = var.msk_broker_nodes

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    client_subnets  = aws_subnet.private[*].id
    security_groups = [aws_security_group.msk_sg.id]
  }

  tags = {
    Name = "${var.project_name}-msk"
  }
}
