# wordpress-test
Sample Infra to create WordPress in AWS


terraform init
terraform plan
terraform apply

We have to make sure Python, AWS cli, Ansible, Terraform all installed

1) Make sure pip is installed
[terraformuser@dockervm ~]$ sudo python --version
Python 2.7.5

# subscription-manager repos --enable rhel-server-rhscl-7-rpms
# yum install python27-python-pip -y
yum install python-devel
# scl enable python27 bash
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ path-to-specific-python-binary/python get-pip.py`
# pip install --upgrade pip

2) Install terraform

curl -O https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip

sudo unzip terraform_0.11.2_linux_amd64.zip -d /bin/terraform/
export PATH=$PATH:/bin/terraform

3) Install AWSCLI

sudo pip install awscli --upgrade

aws --version
aws-cli/1.16.107 Python/2.7.5 Linux/3.10.0-862.el7.x86_64 botocore/1.12.97

4) Install Ansible

sudo yum install ansible
ansible --version
ansible 2.4.2.0

5) set up keys

[terraformuser@dockervm ~]$ sudo ssh-keygen
[sudo] password for terraformuser: 
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/prakashssh
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 

6) terraformuser@dockervm ~]$ sudo ssh-agent bash
[root@dockervm terraformuser]# ssh-add /root/.ssh/prakashssh
Identity added: /root/.ssh/prakashssh (/root/.ssh/prakashssh)

7) Create IAM user in AWS console

user name terraformuser
attach Administrator Policy
create user

8) Download the access keys

9) Go to Route53 
   - make sure a domain name exists

10) set up the access key id

root@dockervm prakash-ansible]# aws configure --profile awsprakash
[root@dockervm prakash-ansible]# aws configure --profile awsprakash
AWS Access Key ID [None]: xxxxxxxxxxxxxxxxxxxx
AWS Secret Access Key [None]: xxxxxxxxxxxxxxxxxx
Default region name [None]: us-west-2
Default output format [None]: txt
[root@dockervm prakash-ansible]# 

[root@dockervm prakash-ansible]# aws ec2 describe-instances --profile awsprakash


11) create reusable delegation set

aws route53 create-reusable-delegation-set --caller-reference 1224 --profile awsprakash

https://route53.amazonaws.com/2013-04-01/delegationset/xxxxxxxxxxxx
DELEGATIONSET	1224	/delegationset/xxxxxxxxxxxxxx
NAMESERVERS	ns-663.awsdns-18.net
NAMESERVERS	ns-1751.awsdns-26.co.uk
NAMESERVERS	ns-101.awsdns-12.com
NAMESERVERS	ns-1034.awsdns-01.org


12) now go to AWS console click your domain ansd add/edit name servers
put the above name servers there
also go to hosted zones and put the same name servers

13) create all the terroaform files
define the terraform variables

14) terraform init
terraform plan

This will just display green empty bits, this shows all is working

now add all the terraform bits in main.tf
and try terraform plam

now add VOC code
add router code
etc..
etc..

finally format the code

terraform fmt --diff


20) to find AWS redhat image id
try seraching in AWS public images with query
"Owner: 309956199498"

also make sure to put a single line inside userdata file

[root@dockervm prakash-ansible]# ssh-agent bash
[root@dockervm prakash-ansible]# ssh-add /root/.ssh/prakashssh

As we are using RedHat linux make sure to add the following
a) Disable selinux on all instances while provisioning
b) install aws cli on all instances as it will not come as default in RedHat

