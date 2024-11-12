resource "aws_acm_certificate" "web_cert" {
  domain_name       = "interview.dev-tcetra.com"
  validation_method = "DNS"

  tags = {
    Name = "Interview ALB Certificate"
  }
}

resource "aws_route53_record" "web_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.web_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.dev_tcetra.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "web_cert_validation" {
  certificate_arn         = aws_acm_certificate.web_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.web_cert_validation : record.fqdn]
}
