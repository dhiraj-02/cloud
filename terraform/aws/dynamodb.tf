resource "aws_dynamodb_table" "analytics" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "courseId"

  attribute {
    name = "courseId"
    type = "S"
  }
}
