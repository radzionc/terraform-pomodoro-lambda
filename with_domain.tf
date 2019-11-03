resource "aws_api_gateway_domain_name" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  certificate_arn = "${var.certificate_arn}"
  domain_name     = "${var.name}.${var.main_domain}"
}
resource "aws_route53_record" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  name    = "${aws_api_gateway_domain_name.api[0].domain_name}"
  type    = "A"
  zone_id = "${var.zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.api[0].cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api[0].cloudfront_zone_id}"
  }
}
resource "aws_api_gateway_base_path_mapping" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  api_id      = "${aws_api_gateway_rest_api.api[0].id}"
  stage_name  = "${aws_api_gateway_deployment.api[0].stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api[0].domain_name}"
}