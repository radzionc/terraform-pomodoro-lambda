resource "aws_api_gateway_domain_name" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  certificate_arn = "${data.terraform_remote_state.certificates.outputs.certificate_arn_virginia_star}"
  domain_name     = "${var.name}.${var.main_domain}"
}
resource "aws_route53_record" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  name    = "${aws_api_gateway_domain_name.api.domain_name}"
  type    = "A"
  zone_id = "${data.terraform_remote_state.global_route.outputs.prod_zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.api.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api.cloudfront_zone_id}"
  }
}
resource "aws_api_gateway_base_path_mapping" "api" {
  count = "${var.main_domain != "" ? 1 : 0}"

  api_id      = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_deployment.api.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api.domain_name}"
}