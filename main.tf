provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#------- IAM -------

#s3_access

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
     }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "Service": "ec2.amazonaws.com"
    },
     "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}

#----- VPC -----

resource "aws_vpc" "wp_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "wp_vpc"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "wp_internet_gateway" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  tags {
    Name = "wp_igw"
  }
}

#Route Tables

resource "aws_route_table" "wp_public_rt" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_internet_gateway.id}"
  }

  tags {
    Name = "wp_public"
  }
}

resource "aws_default_route_table" "wp_private_rt" {
  default_route_table_id = "${aws_vpc.wp_vpc.default_route_table_id}"

  tags {
    Name = "wp_private"
  }
}

#Subnets

resource "aws_subnet" "wp_public1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_public1"
  }
}

resource "aws_subnet" "wp_public2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_public2"
  }
}

resource "aws_subnet" "wp_private1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_private1"
  }
}

resource "aws_subnet" "wp_private2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_private2"
  }
}

resource "aws_subnet" "wp_rds1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_rds1"
  }
}

resource "aws_subnet" "wp_rds2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_rds2"
  }
}

resource "aws_subnet" "wp_rds3_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "wp_rds3"
  }
}

#rds subnet grps
resource "aws_db_subnet_group" "wp_rds_subnetgroup" {
  name = "wp_rds_subnetgroup"

  subnet_ids = ["${aws_subnet.wp_rds1_subnet.id}",
    "${aws_subnet.wp_rds2_subnet.id}",
    "${aws_subnet.wp_rds3_subnet.id}",
  ]

  tags {
    Name = "wp_rds_sng"
  }
}

#Subnet route table associations

resource "aws_route_table_association" "wp_public1_assoc" {
  subnet_id      = "${aws_subnet.wp_public1_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_public2_assoc" {
  subnet_id      = "${aws_subnet.wp_public2_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_private1_assoc" {
  subnet_id      = "${aws_subnet.wp_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

resource "aws_route_table_association" "wp_private2_assoc" {
  subnet_id      = "${aws_subnet.wp_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

#resource "aws_route_table_association" "wp_rds_assoc" {
#   subnet_id = "${aws_subnet.wp_rds_subnetgroup.id}"
#   route_table_id = "${aws_default_route_table.wp_private_rt.id}"
#}

#Security groups
#elb , dev , app instances, rds instances

#dev sg
resource "aws_security_group" "wp_dev_sg" {
  name        = "wp_dev_sg"
  description = "access dev instance sg"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #ssh access from my laptop
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #http access from everywhere
  #this shouldnt be the case in actual env

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    # cidr_blocks = ["${var.localip}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Public security group
#elb sg

resource "aws_security_group" "wp_public_sg" {
  name        = "wp_public_sg"
  description = "public access via load balancer"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #http access

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private security group
#app instances sg

resource "aws_security_group" "wp_private_sg" {
  name        = "wp_private_sg"
  description = "private access inside vpc to connect app instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #http access

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private rds security group
#rds instances sg

resource "aws_security_group" "wp_rds_sg" {
  name        = "wp_RDS_sg"
  description = "private access inside vpc tp RDS instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #http access

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = ["${aws_security_group.wp_dev_sg.id}",
      "${aws_security_group.wp_public_sg.id}",
      "${aws_security_group.wp_private_sg.id}",
    ]
  }
}

# defining VPC endpoint to access S3 resource without
# going via internet gateway for security reasons
# endpoints are linked to private and public
# route tables , so the resources inside the vpc can
# access it

resource "aws_vpc_endpoint" "wp_private-s3_endpoint" {
  vpc_id       = "${aws_vpc.wp_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = ["${aws_vpc.wp_vpc.main_route_table_id}",
    "${aws_route_table.wp_public_rt.id}",
  ]

  policy = <<POLICY
{
   "Statement": [
     {
       "Action": "*",
       "Effect": "Allow",
       "Resource": "*",
       "Principal": "*"
     }
  ]
}
POLICY
}

#defining the actual S3 code bucket

#define a randon number to prepend to s3 url
#to avoid conflicts
resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

#define it as a provate bucket as the app instances access it
#via private router     
resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}-${random_id.wp_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "code bucket"
  }
}

#-------- RDS ---------------
# mysql rds
#the db instance should be linked to the subnet group defined for rds
resource "aws_db_instance" "wp_db" {
  # in GBs
  allocated_storage = 10
  engine            = "mysql"
  engine_version    = "5.6.34"

  #size of the server
  instance_class = "${var.db_instance_class}"

  #name of the db
  name                   = "${var.dbname}"
  username               = "${var.dbuser}"
  password               = "${var.dbpassword}"
  db_subnet_group_name   = "${aws_db_subnet_group.wp_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_rds_sg.id}"]

  #make this true to allow to destroy resources fully
  skip_final_snapshot = true
}

#------ Dev Server -------
#key pair to ssh to dev box

resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#dev server instance
resource "aws_instance" "wp_dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "wp_dev"
  }

  key_name               = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.wp_public1_subnet.id}"

  #define ansible playbook to provision the env
  # we can split it seperately to diff playbook
  # and use aws dynamic inventory as well in actual environment
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.wp_dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_dev.id} --profile ${var.aws_profile} && ansible-playbook -i aws_hosts wordpress.yml"
  }
}

#monitoring server

resource "aws_instance" "wp_monitor" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "wp_monitor"
  }

  key_name               = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.wp_public1_subnet.id}"

#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF > aws_hosts_monitor 
#[monitor] 
#${aws_instance.wp_monitor.public_ip} 
#[monitor:vars] 
#domain=${var.domain_name} 
#EOF
#EOD
#  }

#  provisioner "local-exec" {
#    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_monitor.id} --profile ${var.aws_profile} && ansible-playbook -i aws_hosts_monitor monitoring.yml"
#  }
}


#----- Load balancer ------
# this is elastic or classic load balancer as this is simple however
# we should be using application load balancer in actual
# implementation
# link this elb to public subnets and public security groups
resource "aws_elb" "wp_elb" {
  name = "${var.domain_name}-elb"

  subnets = ["${aws_subnet.wp_public1_subnet.id}",
    "${aws_subnet.wp_public2_subnet.id}",
  ]

  security_groups = ["${aws_security_group.wp_public_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:80"
    interval            = "${var.elb_interval}"
  }

  #request distrubuted to all AZ
  cross_zone_load_balancing = true

  #timeout
  idle_timeout = 400

  #finish receiving traffic befor elb is destroyed
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "wp_${var.domain_name}-elb"
  }
}

#----Golden AMI Image -----
#random ami id
resource "random_id" "golden_ami" {
  byte_length = 3
}

# actual AMI

resource "aws_ami_from_instance" "wp_golden" {
  name               = "wp_ami-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.wp_dev.id}"

  # thiscron job  will goes into each instance created
  # the cron job will check for any changes every 5 minutes
  # and pull the change from s3 code bucket
  # this is not an ideal way to do this we could be using
  # AWS EFS file share to optimize

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html' >> /var/spool/cron/root
EOF
EOT
  }
}

# ------------- launch configuration --------------------
# auto scaling

resource "aws_launch_configuration" "wp_lc" {
  name_prefix          = "wp_lc-"
  image_id             = "${aws_ami_from_instance.wp_golden.id}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.wp_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name             = "${aws_key_pair.wp_auth.id}"
  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}

#AUTO SCALING GRP

resource "aws_autoscaling_group" "wp_asg" {
  name                      = "asg-${aws_launch_configuration.wp_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_elb.wp_elb.id}"]

  #zones for auto scaling grp to deploy instances
  # specify the private subnet to auto scaling grp
  vpc_zone_identifier = ["${aws_subnet.wp_private1_subnet.id}",
    "${aws_subnet.wp_private2_subnet.id}",
  ]

  launch_configuration = "${aws_launch_configuration.wp_lc.name}"

  tag {
    key                 = "Name"
    value               = "wp_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------ Route 53 config -------

#Primary Zone

resource "aws_route53_zone" "primary" {
   name = "${var.domain_name}.com"
   delegation_set_id = "${var.delegation_set}"
}

#WWW

resource "aws_route53_record" "www" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "www.${var.domain_name}.com"
   type = "A"

   #This is required fo elb to follow update ip
   # address
   alias {
     name = "${aws_elb.wp_elb.dns_name}"
     zone_id = "${aws_elb.wp_elb.zone_id}"
     evaluate_target_health = false
   }
}

#dev

resource "aws_route53_record" "dev" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "dev.${var.domain_name}.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.wp_dev.public_ip}"]
}

#private zone

resource "aws_route53_zone" "secondary" {
   name = "${var.domain_name}.com"
   vpc_id = "${aws_vpc.wp_vpc.id}"
}

#db record

resource "aws_route53_record" "db" {
   zone_id = "${aws_route53_zone.secondary.zone_id}"
   name = "db.${var.domain_name}.com"
   type = "CNAME"
   ttl = "300"
   records = ["${aws_db_instance.wp_db.address}"]
}
