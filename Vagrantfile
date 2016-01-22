# This guide is optimized for Vagrant 1.7 and above.
# Although versions 1.6.x should behave very similarly, it is recommended
# to upgrade instead of disabling the requirement below.
Vagrant.require_version ">= 1.7.0"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define "main"

    config.vm.box = "ubuntu/trusty64"

    config.vm.network :forwarded_port, guest: 8000, host: 80
    config.vm.network :forwarded_port, guest: 8001, host: 81
    config.vm.network :forwarded_port, guest: 8080, host: 8080
    config.vm.network :forwarded_port, guest: 8081, host: 8081

    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
    end

    # Disable the new default behavior introduced in Vagrant 1.7, to
    # ensure that all Vagrant machines will use the same SSH key pair.
    # See https://github.com/mitchellh/vagrant/issues/5005
    config.ssh.insert_key = false

    #config.vm.provision "docker"

    # Install Ansible
    #config.vm.provision "shell", inline: "sudo apt-get install -y -q software-properties-common"
    #config.vm.provision "shell", inline: "sudo apt-add-repository ppa:ansible/ansible"
    #config.vm.provision "shell", inline: "sudo apt-get update -q"
    #config.vm.provision "shell", inline: "sudo apt-get install -y -q ansible"
    #config.vm.provision "shell", inline: "sudo easy_install pip"
    #config.vm.provision "shell", inline: "sudo pip install ansible"

    config.vm.provision "ansible" do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "hippo-provision.yml"
        ansible.raw_arguments  = ["--extra-vars='{\"provider\":\"vagrant\"}' --skip-tags \"loadbalancers\""]
    end
end