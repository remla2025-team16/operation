# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Configurable environment variables
  workers = ENV.fetch("WORKERS", 2).to_i
  cpu_ctrl = ENV.fetch("CPU_CTRL", "1")
  mem_ctrl = ENV.fetch("MEM_CTRL", "4096")
  cpu_node = ENV.fetch("CPU_NODE", "2")
  mem_node = ENV.fetch("MEM_NODE", "6144")

  # Base box setup
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202502.21.0"

  # Controller definition
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = mem_ctrl
      vb.cpus = cpu_ctrl
    end
    ctrl.vm.provision :ansible_local do |ansible|
      ansible.playbook = "/vagrant/ansible/ctrl.yaml"
    end
  end

  # Worker nodes definition
  (1..workers).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = mem_node
        vb.cpus = cpu_node
      end
      node.vm.provision :ansible_local do |ansible|
        ansible.playbook = "/vagrant/ansible/node.yaml"
      end
    end
  end

  # General provisioning
  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "/vagrant/ansible/general.yaml"
    ansible.extra_vars = { "num_workers" => workers }
  end

  # Generate dynamic Ansible inventory
  config.trigger.after :up do |trigger|
    trigger.name = "Generate Ansible Inventory"
    trigger.run = {
      inline: <<-SHELL
        mkdir -p ansible
        echo "[ctrl]" > ansible/inventory.cfg
        echo "ctrl ansible_host=192.168.56.100 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key" >> ansible/inventory.cfg
        echo "" >> ansible/inventory.cfg
        echo "[nodes]" >> ansible/inventory.cfg
        for i in $(seq 1 #{workers}); do
          echo "node-${i} ansible_host=192.168.56.$((100 + i)) ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/node-${i}/virtualbox/private_key" >> ansible/inventory.cfg
        done
      SHELL
    }
  end
end
