# module "asg_sg" {
#   source = "terraform-aws-modules/security-group/aws//modules/http-80"

#   name        = "asg-security-group"
#   description = "Security group for web-server with HTTP ports open within VPC"
#   vpc_id      = module.my_vpc.vpc_id

#   ingress_cidr_blocks = ["10.10.0.0/16"]
# }

#create security groups ===========================================================
resource "aws_security_group" "asg_securitygroup" {
  name        = "ASG-securitygroup"
  description = "asg security group"
  vpc_id = module.my_vpc.vpc_id

  # ingress {
  #   description      = "HTTPS"
  #   from_port        = 443
  #   to_port          = 443
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # ingress {
  #   description      = "HTTP"
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "ASG-securitygroup"
  }
}