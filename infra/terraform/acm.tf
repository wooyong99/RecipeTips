# acm
resource "aws_acm_certificate" "recipe-acm" {
  domain_name       = "recipetips.net"
  validation_method = "DNS"

  tags = {
    Environment = "${var.tag}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# cert validation
resource "aws_route53_record" "domain-vali" {
  for_each = {
    for dvo in aws_acm_certificate.recipe-acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.recipe-host.zone_id
}


# acm validation
resource "aws_acm_certificate_validation" "acm-vali" {
  timeouts {
    create = "10m"
  }

  certificate_arn         = aws_acm_certificate.recipe-acm.arn
  validation_record_fqdns = [for record in aws_route53_record.domain-vali : record.fqdn]
}