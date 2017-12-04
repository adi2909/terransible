#Define the security groups, ELB, Launch Configuration, Autoscaling Group

#Security Group for App

resource "aws_security_group" "app_security_group" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["IP address from where you want SSH access"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = ["${aws_security_group.app_security_group.id}"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Group for ELB

resource "aws_security_group" "elb_security_group" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}


#Application Load Balancer

resource "aws_elb" "app_load_balancer" {
  name = "Application ELB"
  security_groups = ["${aws_security_group.elb_security_group.id}"]
  subnets = ["${split(",", var.public_subnet_ids)}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
  }

  connection_draining = true
  connection_draining_timeout = 30

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 5
    target = "http:80/ping"
    interval = 30
  }

  security_groups = ["${aws_security_group.elb_security_group.id}"]
  subnets = ["${split(",", var.public_subnet_ids)}"]

  tags {
    Name = "App ELB"
    #Env = "${var.env}"  (Can be used when using this across multiple envs
  }
}


#AutoScale Group

resource "aws_autoscaling_group" "app_autoscaling_group" {
  max_size = 9
  min_size = 9
  launch_configuration = "${aws_launch_configuration.app_launch_configuration.name}"
  vpc_zone_identifier = ["${split(",", var.public_subnet_ids)}"]
  load_balancers = ["${aws_elb.app_load_balancer.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "App AutoScaling Group"
    propagate_at_launch = true
  }

  tag {
    key = "System"
    value = "${var.system_tag}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Launch Config

resource "aws_launch_configuration" "app_launch_configuration" {
  image_id = "ami-xxxxxxxx" # Look up the latest AMI ID for the region of choice
  instance_type = "t2.micro" #or desired instance type
  security_groups = ["${aws_security_group.app_security_group.id}"]
  associate_public_ip_address = true
  key_name = "${var.instance_keyname}"
  user_data = "${file("${path.module}/user-data.sh")}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "10" #could be a variable as well if you have different sizes for different envs
  }

  lifecycle {
    create_before_destroy = true
  }
}