# hippo-production-example
Example provisioning of infrastructure and build for a Hippo project deployment.

Builds upon [daniel-rhoades/hippo-tomcat-template](https://github.com/daniel-rhoades/hippo-tomcat-template) to provision a representative environment that you could use to run your Hippo project in production.

The project has been written such that you can check and get running without any knowledge of Hippo or infrastructure provisioning.  There are two deployment options:

* Development environment that is representative of production configuration, uses [Vagrant](https://www.vagrantup.com);
* Production environment running on AWS.

Both options make heavy use of [Ansible](http://www.ansible.com) to codify the infrastructure, although, again you don't need to know anything about Ansible to get it running.

If you want to use this project as a template for your own deployment I would recommend forking it so you can receive patch updates more easily.

## Architecture

Please see the [hippo-production-example wiki](https://github.com/daniel-rhoades/hippo-production-example/wiki) for detailed information on the [Architecture](https://github.com/daniel-rhoades/hippo-production-example/wiki/Architecture).

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

## Quick start (AWS)

0. Prerequisites
1. Specify your environment settings
2. Run the provisioning script

## Prerequisites

* [Install Ansible](http://www.ansible.com);
* Register for an AWS account;
* Create an IAM user and SSH key in AWS for Ansible to use.

## Specify your environment settings

* Choose appropriate environment tags;
* Specify database credentials;
* Specify AWS credentials.

## Run the provisioning script

The entire solution as outlined in the architecture is provisioned by simply running:

```
$ ansible-playbook hippo-provision.yml --extra-vars '@myenv.json' --private-key=<my-ssh-key> -u ubuntu
```

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

* Immutable infrastructure;
* Logging, monitoring and alerting;
* Auto-scaling;
* Blue/green deployment.
