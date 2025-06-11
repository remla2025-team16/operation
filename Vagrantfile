workers = ENV.fetch("WORKERS", 2).to_i
cpu_ctrl = ENV.fetch("CPU_CTRL", "2").to_i
mem_ctrl = ENV.fetch("MEM_CTRL", "4096").to_i
cpu_node = ENV.fetch("CPU_NODE", "2").to_i
mem_node = ENV.fetch("MEM_NODE", "6144").to_i

inventory = "[ctrl]\nctrl ansible_host=192.168.56.100 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key\n\n[nodes]\n"
(1..workers).each do |i|
  inventory += "node-#{ i } ansible_host=192.168.56.#{100 + i} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/node-#{ i }/virtualbox/private_key\n"
end

File.write("ansible/inventory.cfg", inventory)

Vagrant.configure("2") do |config|

  # General provisioning
  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "/vagrant/ansible/general.yaml"
    ansible.extra_vars = { "num_workers" => workers }
  end

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
      ansible.inventory_path = "/vagrant/ansible/inventory.cfg"
    end
    ctrl.vm.provision :ansible_local do |ansible|
      ansible.playbook       = "/vagrant/ansible/finalization.yml"
      ansible.inventory_path = "/vagrant/ansible/inventory.cfg"
      ansible.limit          = "ctrl"
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
        ansible.inventory_path = "/vagrant/ansible/inventory.cfg"
      end
    end
  end
end
