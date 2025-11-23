################################################################
# Lambda IAM Role + Managed Policy Attachments
################################################################
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# CloudWatch logs (basic execution)
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 read permission (managed policy)
resource "aws_iam_role_policy_attachment" "lambda_s3_read" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

################################################################
# Lambda Function (local zip file)
################################################################
resource "aws_lambda_function" "file_processor" {
  # local zip path relative to this module (terraform/aws)
  filename         = "${path.module}/../lambda/lambda-function.zip"
  function_name    = "${var.project_name}-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda-function.zip")
  runtime          = "python3.10"

  # Optional: memory/timeouts (tweak as needed)
  memory_size      = 128
  timeout          = 30
}

################################################################
# Allow S3 to invoke Lambda (permission)
################################################################
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.content.arn
}

################################################################
# S3 Bucket Notification -> invoke Lambda on object create
# (Depends on the permission above)
################################################################
resource "aws_s3_bucket_notification" "s3_to_lambda" {
  bucket = aws_s3_bucket.content.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_processor.arn
    events              = ["s3:ObjectCreated:*"]
    # optional filters:
    # filter_prefix = "uploads/"
    # filter_suffix = ".txt"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}
