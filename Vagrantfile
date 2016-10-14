# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Not using ubuntu/xenial64 as it has numerous bugs:
  # - https://bugs.launchpad.net/cloud-images/+bug/1567259
  # - https://bugs.launchpad.net/cloud-images/+bug/1569237
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    # Another bug: https://github.com/chef/bento/issues/682
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  config.vm.network "forwarded_port", guest: 8000, host: 8000

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "vagrant.yml"
    ansible.verbose = "v"
  end
end
