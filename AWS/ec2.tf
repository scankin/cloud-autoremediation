#create linux server/VM
resource "aws_instance" "EC2" {
  ami           = "ami-0c293f3f676ec4f90"
  instance_type = "t2.micro"
  #availability_zone = "us-east-1a"
  key_name        = data.aws_key_pair.asg_key.key_name
  # iam_instance_profile = aws_iam_instance_profile.ec2_role_profile
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  
  subnet_id = module.my_vpc.public_subnets[0]
  security_groups = [aws_security_group.asg_securitygroup.id]

  # user_data = "${file("install_gremlin.sh")}"
  user_data = <<EOF
#!/bin/bash
echo $'sudo yum install -y iproute-tc\nsudo curl https://rpm.gremlin.com/gremlin.repo -o /etc/yum.repos.d/gremlin.repo\nsudo yum install -y gremlin gremlind\ngremlin init' >install_gremlin.sh
chmod +x install_gremlin.sh
echo $'9ce1e800-3c90-4cf1-a1e8-003c901cf15a\ncb0d02cb-26a4-434a-8d02-cb26a4034a83' >input.txt
./install_gremlin.sh <input.txt
EOF

  tags = {
    Name = "ubuntu"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.SSM_EC2_role.name}"
}

#sudo yum update
# cd /tmp
# sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
# sudo systemctl enable amazon-ssm-agent
# sudo systemctl start amazon-ssm-agent