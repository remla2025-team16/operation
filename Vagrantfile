workers = ENV.fetch("WORKERS", 2).to_i
cpu_ctrl = ENV.fetch("CPU_CTRL", "4").to_i
mem_ctrl = ENV.fetch("MEM_CTRL", "8192").to_i
cpu_node = ENV.fetch("CPU_NODE", "2").to_i
mem_node = ENV.fetch("MEM_NODE", "6144").to_i

inventory = "[ctrl]\nctrl ansible_host=192.168.56.100 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key\n\n[nodes]\n"
(1..workers).each do |i|
  inventory += "node-#{ i } ansible_host=192.168.56.#{100 + i} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/node-#{ i }/virtualbox/private_key\n"
end

File.write("ansible/inventory.cfg", inventory)

pub_files  = ["../keys/anyan.pub", "../keys/pratham.pub"]
public_keys = pub_files
  .map { |path| File.read(File.expand_path(path, __FILE__)).strip }
  .join("\n")

Vagrant.configure("2") do |config|

  # Base box setup
  config.ssh.insert_key = false
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
    ctrl.vm.provision "inject_ssh_keys", type: "shell", run: "once", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      echo "#{public_keys}" >> /home/vagrant/.ssh/authorized_keys
      chmod 700 /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
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
      node.vm.provision "inject_ssh_keys", type: "shell", run: "once", inline: <<-SHELL
        mkdir -p /home/vagrant/.ssh
        echo "#{public_keys}" >> /home/vagrant/.ssh/authorized_keys
        chmod 700 /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/main-playbook.yaml"
    ansible.inventory_path = "ansible/inventory.cfg"
    ansible.limit = "all"
  end
end
