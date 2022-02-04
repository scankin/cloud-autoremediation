module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = "asg"

  min_size         = 1
  max_size         = 5
  desired_capacity = 2
  #TO DO: look into behavior of wait_for_capacity_timeout, think it means wait to see if instance returns to healthy state before adding new instance
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.my_vpc.public_subnets

  # Launch template
  lt_name                = "lt-asg"
  description            = "Launch template"
  update_default_version = true

  use_lt    = true
  create_lt = true

  image_id          = "ami-08e4e35cccc6189f4"
  instance_type     = "t2.micro"
  ebs_optimized     = false
  enable_monitoring = true

  security_groups = [module.asg_sg.security_group_id]
  key_name        = data.aws_key_pair.asg_key.key_name

  scaling_policies = {
    my-policy = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
          resource_label         = "MyLabel"
        }
        target_value = 40.0
      }
    }
  }

}
