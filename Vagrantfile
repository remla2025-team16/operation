Vagrant.configure("2") do |config|
  workers = ENV.fetch("WORKERS", 2).to_i

  # control node definition
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.box = "bento/ubuntu-24.04"
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100", virtualbox__intnet: "cluster"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 1
    end
  end

  # worker definitions
  (1..workers).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "bento/ubuntu-24.04"
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}", virtualbox__intnet: "cluster"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 6144
        vb.cpus = 2
      end
    end
  end
  
  # Provisioning
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/general.yaml"
    ansible.inventory_path = "ansible/inventory.cfg"
    ansible.extra_vars = { "workers": workers }
    ansible.limit = "all"
  end
end