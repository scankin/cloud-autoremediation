output "domain" {
  value = module.asg.autoscaling_group_name
}
output "subnet" {
  value = module.my_vpc.public_subnets[0]
}