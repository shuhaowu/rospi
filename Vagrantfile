# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 4
  end


  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y qemu-user-static
  SHELL
end
