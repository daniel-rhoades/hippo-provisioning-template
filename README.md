# hippo-provisioning-template
[![Circle CI](https://circleci.com/gh/daniel-rhoades/hippo-provisioning-template.svg?style=svg)](https://circleci.com/gh/daniel-rhoades/hippo-provisioning-template)

Templated provisioning of infrastructure and build for a Hippo CMS project deployment into [AWS](https://aws.amazon.com), to include:

* Networking:
    * [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/);
    * DNS - [Route 53](https://aws.amazon.com/route53/);
    * Load Balancers - [Elastic Load Balancing (ELB)](https://aws.amazon.com/elasticloadbalancing/);
* Compute:
    * Virtual Servers - [Elastic Compute Cloud (EC2)](https://aws.amazon.com/ec2/);
    * [Auto Scaling](https://aws.amazon.com/autoscaling/);
    * Container Service - [EC2 Container Service (ECS)](https://aws.amazon.com/ecs/);
* Database:
    * [Relational Database Service (RDS)](https://aws.amazon.com/rds/).

The playbook will also configure an [ECS Task Definition](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_defintions.html) and [ECS Service](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) to define a collection of Docker containers which represent the CMS: 

* Reverse proxy realised by [Nginx](https://www.nginx.com), using the [official Nginx Docker image](https://hub.docker.com/_/nginx/);
* Application server realised by [Tomcat](https://tomcat.apache.org), configured for use with a Hippo distribution using the [danielrhoades/hippo-tomcat-template Docker image](https://hub.docker.com/r/danielrhoades/hippo-tomcat-template/).

Provisioning currently makes heavy use of [Ansible](http://www.ansible.com) to codify the infrastructure, although, again you don't need to know anything about Ansible to get it running.

Provisioning and configuration steps have been separated out as much as possible.

If you want to use this project as a template for your own deployment I would recommend forking it so you can receive patch updates more easily.

## Architecture

Please see the [hippo-production-template wiki](https://github.com/daniel-rhoades/hippo-provisioning-template/wiki) for detailed information on the [Architecture](https://github.com/daniel-rhoades/hippo-provisioning-template/wiki/Architecture).

## Super quick start

Assuming a *unix environment and all the contextual AWS links are for eu-west-1 (Ireland) region:

1. Clone this project;
2. Clone the following project [daniel-rhoades/ansible-environment](https://github.com/daniel-rhoades/ansible-environment), this will give you the necessary Ansible environment as a virtual machine.  It might take a while as it builds Ansible from source and so needs a lot of dependencies not in the standard Ubuntu image; 
3. Provision a Vagrant environment by running `$ vagrant up development` in the `ansible-environment` project root directory
4. SSH into Vagrant (`$ vagrant ssh development`), your host home directory will be mapped to the directory in the Vagrant virtual machine as `/home/host-machine`
5. Register for an AWS account, create an IAM user, download the access/secret key and attach the following AWS IAM policy to that user:
    * `AdministratorAccess`;
6. Within the AWS console, create an [SSH Key Pair](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName), this will be the key given to all EC2 instances, note the name you give to this Key Pair;
    * I will encorporate this into the playbook soon
7. Run through the [ECS Getting Started](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/firstRun), on step 2 choose the ELB option, then just keep clicking next;
    * This is needed just to create the initial ECS roles;
    * I will encorporate this into the playbook soon
8. `cd` into this project's root directory, source your AWS environment by running `$ eval "$(./aws-ansible.sh <my-access-key> <my-secret-key> <region>)"` replacing the placeholder values with the access/secret key you just created and use whatever region you want;
9. Provision the environment by running: `$ ansible-playbook provision-aws.yml -vvvv -e ssh_key_name=<ssh-key-name> -e my_route53_zone=<your-domain>`, replacing the placeholders with your key name and the name of a domain you have created in AWS Route 53 (example.com);
10. Browse to `http://contentauthoring-gogreen-development.<your-domain>/`, login with admin/admin.  This is the Hippo CMS.  To see the public website browse to `http://contentdelivery-gogreen-development.<your-domain>/`;
    * By default you will need to modify Hippo repository to work in this environment.  To do this follow the Hippo documentation for [Configuring Virtual Hosts in an Environment](http://www.onehippo.org/library/enterprise/installation-and-configuration/configure-virtual-hosts-in-an-environment.html).  Basically, you need to add 3 properties (`defaultHost`, `showPort`, `showContextPath`) to the `hst:hosts` node in the Hippo console;
    * I will encorporate this into the playbook soon.
    
Once you are done you can decommission the environment by running `$ ansible-playbook decommission-aws.yml -vvvv -e ssh_key_name=<ssh-key-name> -e my_route53_zone=<your-domain>`.

## Quick start

0. Prerequisites
1. Specify your environment settings
2. Run the provisioning script

## Prerequisites

* [Install Ansible](http://www.ansible.com) - currently requires a patched 2.1 devel branch;
* Register for an [AWS](http://aws.amazon.com) account;
* Create an admin IAM user and SSH key in AWS for Ansible to use;
* Create an SSH key.

You can use [daniel-rhoades/ansible-environment](https://github.com/daniel-rhoades/ansible-environment), this will build the latest devel branch of Ansible by running `$ vagrant up development` then all you need to do it SSH into the box, e.g. `$ vagrant ssh development`

This document assumes you are familiar with AWS, if not there are a few guides and books out there.

When creating your IAM user in AWS, for a quick start, assign them the following policies:

* AmazonRDSFullAccess
* AmazonEC2FullAccess
* AmazonECSFullAccess

In practice you'll want to fine tune permissions, so that user can only administer infrastructure it needs to.

Remember to also download the user's access/secret key.

You'll also need to create an SSH key, this key will be used to login to the EC2 instances.  Just make sure you download the private key (PEM file).

Run through the [ECS Getting Started](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/firstRun), on step 2 choose the ELB option, then just keep clicking next.  This is needed just to create the initial ECS roles, you can delete the cluster afterwards.

## Specify your environment settings

* Appropriate environment tags;
* RDBMS settings;
* AWS environment credentials;
* Ansible AWS environment;
* Nginx configurations;
* Hippo configurations.

An [example environments script](aws-ansible.sh) to define both AWS and Ansible variables is available.  You would source that in your environment by running within the project root (replacing the placeholders):

```
$ eval "$(./aws-ansible.sh <my-access-key> <my-secret-key> <region>)"
```

### Appropriate environment tags

When you come to running the provisioning script you'll probably want to specify (sensible defaults exist):

* `env`: Defaults to 'development', could be anything those, e.g. the latest commit hash;
* `application`: Defaults to 'gogreen', but I would recommend using a more meaningful name, perhaps your website domain name.

### RDBMS settings

You'll probably want to override the default RDBMS information for the Content Store (sensible defaults exist):

* `contentstore_database_name`: Name of the database instance, defaults to 'gogreen';
* `contentstore_database_username`: Username that Hippo will use to access the database, defaults to 'gogreen';
* `contentstore_database_password`: Password that Hippo will use to access the database, defaults to 'password'.

If the database requires configuring with this information (e.g. you want Ansible to create the database) then they can be specified in an init script.  A [templated MySQL script](roles/hippo-contentstore/files/initialise-db-mysql.sql.j2) has already been prepared which gets used during Vagrant provisioning.

(TODO - Use script during RDS provisioning)

### AWS environment credentials

The AWS provisioning aspects of Ansible require that you define the following environment variables (no defaults exist):

* `AWS_ACCESS_KEY_ID`: For the user who was setup in IAM;
* `AWS_SECRET_ACCESS_KEY`: For the user who was setup in IAM;
* `AWS_REGION`: The AWS region you want to infrastructure to be provisioned within, e.g. eu-west-1

### Ansible AWS environment

If you have used [daniel-rhoades/ansible-environment](https://github.com/daniel-rhoades/ansible-environment) then skip this section, as this step was automated for you.

Firstly, follow Ansible's documentation - [Ansible - Amazon Web Services Guide](http://docs.ansible.com/ansible/guide_aws.html) to setting up Ansible's EC2 module, in particular setup the [AWS EC2 External Inventory Script](http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script).

Then you need to specify:

* `ANSIBLE_HOSTS`: Location of the Ansible EC2 inventory script, e.g. `/etc/ansible/ec2.py`.  This tells Ansible that it's hosts are all in AWS by default;
* `EC2_INI_PATH`: Allows you to (optionally) tune Ansible, if you want, e.g. `/etc/ansible/ec2.ini`. 

### Nginx configuration

A default configuration is provided in this project, but you are likely to need your own one specific to your site, do this via Ansible variables:

* `contentauthoring_reverseproxy_config`: e.g. hippo-cms-entry.sh
* `contentdelivery_reverseproxy_config`: e.g. hippo-site-entry.sh

If you prefer to supply your own Docker image containing Nginx (and all its dependencies), then set that using:

* `contentauthoring_reverseproxy_docker_image`
* `contentdelivery_reverseproxy_docker_image`

Both default to 'nginx' - the official Docker nginx image.

### Hippo configuration

By default the Hippo demo site "gogreen" is deployed from [daniel-rhoades/hippo-gogreen](https://github.com/daniel-rhoades/hippo-gogreen).  Obviously this isn't much use beyond proving the provisioning works.  So to provide your own Hippo distribution use the following variables:

* `contentauthoring_distribution_url`: URL to the CMS archive, e.g. https://github.com/daniel-rhoades/hippo-gogreen/releases/download/v0.1/gogreen-0.1.0-SNAPSHOT-cms-distribution.tar.gz
* `contentdelivery_distribution_url`: URL to the "site" archive, e.g. https://github.com/daniel-rhoades/hippo-gogreen/releases/download/v0.1/gogreen-0.1.0-SNAPSHOT-site-distribution.tar.gz

If you prefer to supply your own Docker image containing Hippo, then set that using:

* `contentauthoring_appserver_docker_image`
* `contentdelivery_appserver_docker_image`

Both default to [danielrhoades/hippo-tomcat-template](https://github.com/daniel-rhoades/hippo-tomcat-template).

## Run the provisioning script

The entire solution as outlined in the architecture is provisioned by simply running:

```
$ ansible-playbook provision-aws.yml -vvvv -e ssh_key_name=<iam-ssh-key-name> -e my_route53_zone=<domain-name>
```

The `--private key` is the file location of private SSH key (the PEM file) you got from AWS.  The user is the default user for the AWS image you are using, by default this is Ubuntu, so the user is "ubuntu".

That's it, in around 45mins you will have a complete Hippo production setup in your AWS account.  By far the longest period of provisioning the database taking around 80% of the overall time.

Due to the complexity of the whole thing, timeouts can occur.  Don't worry just re-run the playbook.  Ansible is id-impotent, so it knows not to do things twice.

## Manage your Hippo environment

Once you are done with your Hippo setup and have it all working you have three options:

1. Leave it alone! It works!
2. Stop or scale the number of web server instances; 
3. Terminate the entire environment.

The Ansible playbooks in this project will automate doing all those things for you.

# Next steps

Soon I plan to add the following to the build:

* Consider Terraform integration;
* SSL configuration;
* AWS Cloudfront and AWS WAF options (automation thereof);
* Immutable infrastructure;
* Logging, monitoring and alerting;
* Blue/green deployment;
* Security improvements.
