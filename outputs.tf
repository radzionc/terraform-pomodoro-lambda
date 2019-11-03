output "function_arn" {
  value = "${aws_lambda_function.service.arn}"
}

output "function_name" {
  value = "${aws_lambda_function.service.function_name}"
}