output "alb_dns_name" {
  description = "Public URL of the application"
  value       = aws_lb.app_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}
