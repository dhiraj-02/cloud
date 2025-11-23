########################################################
# GLOBAL
########################################################
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project prefix for naming resources"
  type        = string
  default     = "cloud-assignment"
}

########################################################
# VPC
########################################################
variable "vpc_cidr" {
  description = "CIDR for main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

########################################################
# EKS
########################################################
variable "eks_cluster_name" {
  type    = string
  default = "edu-eks"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_group_size" {
  type    = number
  default = 2
}

########################################################
# RDS
########################################################
variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type        = string
  sensitive   = true
  default     = "Test12345!"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

########################################################
# S3
########################################################
variable "content_bucket_name" {
  type    = string
  default = "cloud-assignment-content-bucket-02"
}

########################################################
# LAMBDA
########################################################
variable "lambda_s3_key" {
  type        = string
  default     = "lambda-function.zip"
}

variable "lambda_handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

########################################################
# MSK
########################################################
variable "msk_cluster_name" {
  type    = string
  default = "edu-msk-cluster"
}

variable "msk_instance_type" {
  type    = string
  default = "kafka.m5.large"
}

variable "msk_broker_nodes" {
  description = "Number of MSK broker nodes (must be multiple of number of AZs/subnets)"
  type        = number
  default     = 2
}


########################################################
# DYNAMODB
########################################################
variable "dynamodb_table_name" {
  type    = string
  default = "analytics-results"
}

########################################################
# ARGOCD
########################################################
variable "argocd_namespace" {
  type    = string
  default = "argocd"
}
