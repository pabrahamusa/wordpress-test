aws_profile = "awsprakash"
# For time being only considering San Francisco region to 
# reduce complexity as this is a test. However we can
# create multi region spanning infra implementation to consider
# Tokyo users as well i.e. ap-northeast-1 (Asia Pacific)
#us-west-1 , N.California close to SanFrancisco but dont have
#enough avaliability zones so choosing Oregon i.e. us-west-2
aws_region  = "us-west-2"
vpc_cidr    = "10.0.0.0/16"
cidrs       = {
   public1 = "10.0.1.0/24"
   public2 = "10.0.2.0/24"
   private1 = "10.0.3.0/24"
   private2 = "10.0.4.0/24"
   rds1     = "10.0.5.0/24"
   rds2     = "10.0.6.0/24"
   rds3     = "10.0.7.0/24"
}

# 32 only single ip, my laptop ip
localip = "72.209.207.187/32"
domain_name = "devops-prakash"
db_instance_class = "db.t2.micro"
dbname = "prakashdb"
dbuser = "prakash"
dbpassword = "prakashpass"
dev_instance_type = "t2.micro"
#obtained image id by searching public images for RedHat owner
dev_ami = "ami-9fa343e7"
public_key_path = "/root/.ssh/prakashssh.pub"
key_name = "prakashssh"
elb_healthy_threshold = "2"
elb_unhealthy_threshold = "2"
elb_timeout = "3"
elb_interval = "30"
#max 2 for low cost
asg_max = "2"
asg_min = "1"
asg_grace = "300"
#health check type
asg_hct = "EC2"
asg_cap = "2"
lc_instance_type = "t2.micro"
delegation_set = "N1SO86C16UHWUW"
  
