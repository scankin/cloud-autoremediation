resource "aws_autoscaling_notification" "cpu_notifications" {
  group_names = [
    module.asg.autoscaling_group_name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.sns.arn
}

resource "aws_sns_topic" "sns" {
  name = "cpu-topic"
  # arn is an exported attribute
}

# resource "aws_autoscaling_notification" "cpu_notifications2" {
#   group_names = [
#     module.asg.autoscaling_group_name,
#   ]

#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCHING",
#   ]

#   topic_arn = aws_sns_topic.sns_for_asg_role.arn
# }

# resource "aws_sns_topic" "sns_for_asg_role" {
#   name = "cpu-topic"
#   # arn is an exported attribute
# }