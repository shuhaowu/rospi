# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Not using ubuntu/xenial64 as it has numerous bugs:
  # - https://bugs.launchpad.net/cloud-images/+bug/1567259
  # - https://bugs.launchpad.net/cloud-images/+bug/1569237
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "vagrant.yml"
    ansible.verbose = "v"
    ansible.sudo = true
    ansible.ask_vault_pass = true if ENV["ROSPI_SECRET"]
  end
end
