module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = "asg"

  min_size         = 1
  max_size         = 5
  desired_capacity = 1
  #TO DO: look into behavior of wait_for_capacity_timeout, think it means wait to see if instance returns to healthy state before adding new instance
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.my_vpc.public_subnets

  # initial_lifecycle_hooks = [
  #   {
  #     name                  = "ExampleStartupLifeCycleHook"
  #     default_result        = "CONTINUE"
  #     heartbeat_timeout     = 60
  #     lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
  #     notification_target_arn = "${aws_sns_topic.sns_for_asg_role.arn}"
  #     role_arn = "${aws_iam_role.SSM_EC2_role.arn}"
  #   }
  # ]


  # Launch config
  lc_name                = "lt-asg"
  description            = "Launch template"
  update_default_version = true

  use_lc    = true
  create_lc = true

  image_id          = "ami-08e4e35cccc6189f4"
  instance_type     = "t2.micro"
  ebs_optimized     = false
  enable_monitoring = true

  #security_groups = [module.asg_sg.security_group_id]
  security_groups = [aws_security_group.asg_securitygroup.id]
  key_name        = data.aws_key_pair.asg_key.key_name
  
  user_data = <<EOF
#!/bin/bash
echo $'sudo yum install -y iproute-tc\nsudo curl https://rpm.gremlin.com/gremlin.repo -o /etc/yum.repos.d/gremlin.repo\nsudo yum install -y gremlin gremlind\ngremlin init' >install_gremlin.sh
chmod +x install_gremlin.sh
echo $'9ce1e800-3c90-4cf1-a1e8-003c901cf15a\ncb0d02cb-26a4-434a-8d02-cb26a4034a83' >input.txt
./install_gremlin.sh <input.txt
EOF

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

resource "aws_iam_instance_profile" "ec2_role_profile" {
  name = "ec2_profile"
  role = "${aws_iam_role.SSM_EC2_role.name}"
}
