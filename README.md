# hippo-provisioning-template
[![Circle CI](https://circleci.com/gh/daniel-rhoades/hippo-provisioning-template.svg?style=svg)](https://circleci.com/gh/daniel-rhoades/hippo-provisioning-template)

Templated provisioning of infrastructure and build for a Hippo project deployment, to include:

* DNS
* Networking
* Load Balancers
* Web Servers (hosting [Nginx](https://www.nginx.com) and [Hippo](http://www.onehippo.org) on [Docker](https://www.docker.com))
* Database server

Builds upon [daniel-rhoades/hippo-tomcat-template](https://github.com/daniel-rhoades/hippo-tomcat-template) to provision a representative environment that you could use to run your Hippo project in production.

The project has been written such that you can check and get running without any knowledge of Hippo or infrastructure provisioning.  There are two deployment options:

* Development environment that is representative of production configuration, uses [Vagrant](https://www.vagrantup.com);
* Production environment running on [AWS](http://aws.amazon.com).

Both options make heavy use of [Ansible](http://www.ansible.com) to codify the infrastructure, although, again you don't need to know anything about Ansible to get it running.

Provisioning and configuration steps have been separated out as much as possible, such that the Ansible playbook will configure webservers regardless of how/where they are provisioned.

If you want to use this project as a template for your own deployment I would recommend forking it so you can receive patch updates more easily.

## Architecture

Please see the [hippo-production-example wiki](https://github.com/daniel-rhoades/hippo-provisioning-template/wiki) for detailed information on the [Architecture](https://github.com/daniel-rhoades/hippo-provisioning-template/wiki/Architecture).

## Super quick start (Vagrant)

1. [Install Vagrant](https://docs.vagrantup.com/v2/installation/index.html);
2. [Clone](https://help.github.com/articles/cloning-a-repository/) this project from GitHub;
3. In the project directory run: `$ vagrant up`

You should now be able to login to Hippo, the default username/password for Hippo is admin/admin:

* http://localhost/cms
* http://localhost/site

The CMS component is where you administer the website and the HST ("site") is the public facing side.

If you get any errors during provisioning, then it's usually because some dependency (usually Oracle JDK) failed to download, just run:

* `$ vagrant reload`
* `$ vagrant provision`

That will re-provision your environment and should clear up any errors.

Now, this is a development environment only, it's representative of a production setup, useful for debugging issues, but it ain't production!  It all runs on a single VM, but in separate Docker containers.  So from a Docker point of view its no different (mostly), but don't rely on it, always test on an identical (near as) to your live environment.

The environment is built almost identically to [daniel-rhoades/hippo-tomcat-template](https://github.com/daniel-rhoades/hippo-tomcat-template) Vagrant setup, but with two important differences:

* The same Ansible playbook used for other target hosting providers (e.g. AWS) is used, but their are specific steps for Vagrant;
* Nginx has been configured as the reverse proxy for Hippo.

## Quick start (AWS)

0. Prerequisites
1. Specify your environment settings
2. Run the provisioning script

## Prerequisites

* [Install Ansible](http://www.ansible.com);
* Register for an [AWS](http://aws.amazon.com) account;
* Create an admin IAM user and SSH key in AWS for Ansible to use;
* Create an SSH key.

This document assumes you are familiar with AWS, if not there are a few guides and books out there.

When creating your IAM user in AWS, for a quick start, assign them the following policies:

* AmazonRDSFullAccess
* AmazonEC2FullAccess

In practice you'll want to fine tune permissions, so that user can only administer infrastructure it needs to.

Remember to also download the user's access/secret key.

You'll also need to create an SSH key, this key will be used to login to the EC2 instances.  Just make sure you download the private key (PEM file).

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

A [complete example variables script](vagrant-env.json) is also available which is actually used during Vagrant provisioning, or an AWS example, which just accepts the defaults, providing on the necessary information [aws-env.json](aws-env.json).  Ansible accepts your variables in either YAML or JSON formats, the example used here is JSON.  Investigate vars/*.yml and vars/aws/*.yml for a complete list of variables you can override.

### Appropriate environment tags

When you come to running the provisioning script you'll need to specify:

* `env`: Defaults to 'development', could be anything those, e.g. the latest commit hash;
* `application`: Defaults to 'gogreen', but I would recommend using a more meaningful name, perhaps your website domain name.

### RDBMS settings

You'll want to override the default RDBMS information for the Content Store:

* `contentstore_database_name`: Name of the database instance, defaults to 'gogreen';
* `contentstore_database_username`: Username that Hippo will use to access the database, defaults to 'gogreen';
* `contentstore_database_password`: Password that Hippo will use to access the database, defaults to 'password'.

If the database requires configuring with this information (e.g. you want Ansible to create the database) then they can be specified in an init script.  A [templated MySQL script](roles/hippo-contentstore/files/initialise-db-mysql.sql.j2) has already been prepared which gets used during Vagrant provisioning.

(TODO - Use script during RDS provisioning)

### AWS environment credentials

The AWS provisioning aspects of Ansible require that you define the following environment variables:

* `AWS_ACCESS_KEY_ID`: For the user who was setup in IAM;
* `AWS_SECRET_ACCESS_KEY`: For the user who was setup in IAM;
* `AWS_REGION`: The AWS region you want to infrastructure to be provisioned within, e.g. eu-west-1

You also need to provide the `ssh_key-name` in the form of an Ansible variable.

### Ansible AWS environment

Firstly, follow Ansible's documentation - [Ansible - Amazon Web Services Guide](http://docs.ansible.com/ansible/guide_aws.html) to setting up Ansible's EC2 module, in particular setup the [AWS EC2 External Inventory Script](http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script).

Then you need to specify:

* `ANSIBLE_HOSTS`: Location of the Ansible EC2 inventory script, e.g. `/etc/ansible/ec2.py`.  This tells Ansible that it's hosts are all in AWS by default;
* `EC2_INI_PATH`: Allows you to (optionally) tune Ansible, if you want, e.g. `/etc/ansible/ec2.ini`. 

### Nginx configuration

A default configuration is provided in this project, but you are likely to need your own one specific to your site, do this via Ansible variables:

* `contentauthoring_reverseproxy_config`: e.g. hippo-cms.conf.tmpl
* `contentdelivery_reverseproxy_config`: e.g. hippo-site.conf.tmpl

If you prefer to supply your own Docker image containing Nginx (and all its dependencies), then set that using:

* `contentauthoring_reverseproxy_docker_image`
* `contentdelivery_reverseproxy_docker_image`

Both default to 'shepmaster/nginx-template-image'.

### Hippo configuration

By default the Hippo demo site "gogreen" is deployed from [daniel-rhoades/hippo-gogreen](https://github.com/daniel-rhoades/hippo-gogreen).  Obviously this isn't much use beyond proving the provisioning works.  So to provide your own Hippo distribution use the following variables:

* `contentauthoring_distribution_url`: URL to the CMS archive, e.g. https://github.com/daniel-rhoades/hippo-gogreen/releases/download/v0.1/gogreen-0.1.0-SNAPSHOT-cms-distribution.tar.gz
* `contentdelivery_distribution_url`: URL to the "site" archive, e.g. https://github.com/daniel-rhoades/hippo-gogreen/releases/download/v0.1/gogreen-0.1.0-SNAPSHOT-site-distribution.tar.gz

If you prefer to supply your own Docker image containing Hippo (and all its dependencies), then set that using:

* `contentauthoring_appserver_docker_image`
* `contentdelivery_appserver_docker_image`

Both default to 'danielrhoades/hippo-tomcat-template'.

## Run the provisioning script

The entire solution as outlined in the architecture is provisioned by simply running:

```
$ ansible-playbook hippo-provision.yml --extra-vars '@myenv.json' --private-key=<my-ssh-key> -u ubuntu
```

The `--private key` is the file location of private SSH key (the PEM file) you got from AWS.  The user is the default user for the AWS image you are using, by default this is Ubuntu, so the user is "ubuntu".  The `myenv.json` file is a JSON file you create to hold your custom Ansible variables, alternatively you can just pass a JSON string, e.g. `--extra-vars '{"contentstore_database_name":"gogreen"}'`

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
* AWS Cloudfront and AWS WAF options;
* Docker Swarm, AWS ECS or Mesos options;
* Immutable infrastructure;
* Logging, monitoring and alerting;
* Auto-scaling;
* Blue/green deployment;
* Security improvements.
