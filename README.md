############################################################
### wordpress-test
Sample Infra to create WordPress in AWS

############################################################

## Run the following commands to create infra

* terraform init </br>

* terraform plan  </br>

* terraform apply  </br>

We have to make sure Python, AWS cli, Ansible, Terraform all installed

## Make sure pip is installed
    1. [terraformuser@dockervm ~]$ sudo python --version </br>
         Python 2.7.5

    2. subscription-manager repos --enable rhel-server-rhscl-7-rpms </br>
    3. scl enable python27 bash  </br>

    4. curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py </br>

    5. path-to-specific-python-binary/python get-pip.py </br>

    6. pip install --upgrade pip </br>

## Install terraform

     1. curl -O https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip

     2. sudo unzip terraform_0.11.2_linux_amd64.zip -d /bin/terraform/
     3. export PATH=$PATH:/bin/terraform

## Install AWSCLI

     1. sudo pip install awscli --upgrade

     2. aws --version  </br>
           aws-cli/1.16.107 Python/2.7.5 Linux/3.10.0-862.el7.x86_64 botocore/1.12.97

## Install Ansible

     1. sudo yum install ansible
     2. ansible --version  </br>
           ansible 2.4.2.0

## set up keys

1. [terraformuser@dockervm ~]$ sudo ssh-keygen

     [sudo] password for terraformuser:  </br>
           Generating public/private rsa key pair. </br>
           Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/prakashssh </.br>
           
           Created directory '/root/.ssh'.  </br>
              Enter passphrase (empty for no passphrase): </br>
              Enter same passphrase again: </br>

2. terraformuser@dockervm ~]$ sudo ssh-agent bash

3. [root@dockervm terraformuser]# ssh-add /root/.ssh/prakashssh </br>
         Identity added: /root/.ssh/prakashssh (/root/.ssh/prakashssh)

## Create IAM user in AWS console

1. user name terraformuser
2. attach Administrator Policy
3. create user

## Download the access keys

## Go to Route53 </br>
   - make sure a domain name exists

## set up the access key id

1. root@dockervm prakash-ansible]# aws configure --profile awsprakash
2. [root@dockervm prakash-ansible]# aws configure --profile awsprakash
3. AWS Access Key ID [None]: xxxxxxxxxxxxxxxxxxxx
4. AWS Secret Access Key [None]: xxxxxxxxxxxxxxxxxx
5. Default region name [None]: us-west-2
6. Default output format [None]: txt
7. [root@dockervm prakash-ansible]# 
8. [root@dockervm prakash-ansible]# aws ec2 describe-instances --profile awsprakash


## create reusable delegation set

 1. aws route53 create-reusable-delegation-set --caller-reference 1224 --profile awsprakash </br>

https://route53.amazonaws.com/2013-04-01/delegationset/xxxxxxxxxxxx </br>
DELEGATIONSET	1224	/delegationset/xxxxxxxxxxxxxx </br>
NAMESERVERS	ns-663.awsdns-18.net </br>
NAMESERVERS	ns-1751.awsdns-26.co.uk </br>
NAMESERVERS	ns-101.awsdns-12.com </br>
NAMESERVERS	ns-1034.awsdns-01.org </br>


## now go to AWS console click your domain ansd add/edit name servers </br>
put the above name servers there </br>
also go to hosted zones and put the same name servers </br>

## create all the terraform files </br>
    define the terraform variables </br>

## terraform init
## terraform plan

This will just display green empty bits, this shows all is working </br>

now add all the terraform bits in main.tf </br>
and try terraform plan </br>

now add VOC code </br>
add router code </br>
etc.. </br>
etc.. </br>

finally format the code </br>

terraform fmt --diff </br>


## to find AWS redhat image id </br>
try seraching in AWS public images with query </br>
"Owner: 309956199498" </br>

also make sure to put a single line inside userdata file </br>

[root@dockervm prakash-ansible]# ssh-agent bash </br>
[root@dockervm prakash-ansible]# ssh-add /root/.ssh/prakashssh </br>

## As we are using RedHat linux make sure to add the following
a) Disable selinux on all instances while provisioning
b) install aws cli on all instances as it will not come as default in RedHat

