module "asg_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "asg-security-group"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.my_vpc.vpc_id

  ingress_cidr_blocks = ["10.10.0.0/16"]
}