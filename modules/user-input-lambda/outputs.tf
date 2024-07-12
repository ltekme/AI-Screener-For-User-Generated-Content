output "lambda_function" {
  value = aws_lambda_function.user_input
}

output "lambda_role" {
  value = aws_iam_role.lambda_function-user_input
}