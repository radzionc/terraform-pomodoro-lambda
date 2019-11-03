resource "aws_api_gateway_rest_api" "api" {
  count = "${var.with_api_gateway ? 1 : 0}"

  name = "tf-${var.name}"
}

resource "aws_api_gateway_method" "api_root" {
  count = "${var.with_api_gateway ? 1 : 0}"

  rest_api_id   = "${aws_api_gateway_rest_api.api[0].id}"
  resource_id   = "${aws_api_gateway_rest_api.api[0].root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_root" {
  count = "${var.with_api_gateway ? 1 : 0}"

  rest_api_id   = "${aws_api_gateway_rest_api.api[0].id}"
  resource_id   = "${aws_api_gateway_rest_api.api[0].root_resource_id}"
  http_method = "${aws_api_gateway_method.api_root[0].http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.service.invoke_arn}"
}

resource "aws_api_gateway_resource" "api" {
  count = "${var.with_api_gateway ? 1 : 0}"

  rest_api_id = "${aws_api_gateway_rest_api.api[0].id}"
  parent_id   = "${aws_api_gateway_rest_api.api[0].root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api" {
  count = "${var.with_api_gateway ? 1 : 0}"

  rest_api_id   = "${aws_api_gateway_rest_api.api[0].id}"
  resource_id   = "${aws_api_gateway_resource.api.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api" {
  count = "${var.with_api_gateway ? 1 : 0}"

  rest_api_id = "${aws_api_gateway_rest_api.api[0].id}"
  resource_id = "${aws_api_gateway_method.api[0].resource_id}"
  http_method = "${aws_api_gateway_method.api[0].http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.service.invoke_arn}"
}

resource "aws_lambda_permission" "apigw" {
  count = "${var.with_api_gateway ? 1 : 0}"

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.service.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api[0].id}/*/*"
}

module "cors" {
  count = "${var.with_api_gateway ? 1 : 0}"

  source = "github.com/carrot/terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.api.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api[0].id}"
}

resource "aws_api_gateway_deployment" "api" {
  count = "${var.with_api_gateway ? 1 : 0}"

  depends_on = ["module.cors[0]", "aws_api_gateway_integration.api[0]"]
  rest_api_id = "${aws_api_gateway_rest_api.api[0].id}"
  stage_name  = "${var.name}"
}

