# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.5"

unless Vagrant.has_plugin?("vagrant-triggers")
  raise Vagrant::Errors::VagrantError.new, "Please install the vagrant-triggers plugin running 'vagrant plugin install vagrant-triggers'"
end

CONFIG = File.join(File.dirname(__FILE__), "config.rb")
# Defaults for config options defined in CONFIG
$num_instances = 1
$instance_name_prefix = "deis"
$update_channel = ENV["COREOS_CHANNEL"] || "stable"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 2048
$vm_cpus = 1

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
elsif ENV["DEIS_NUM_INSTANCES"].to_i > 0 && ENV["DEIS_NUM_INSTANCES"]
  $num_instances = ENV["DEIS_NUM_INSTANCES"].to_i
else
  $num_instances = 3
end

if File.exist?(CONFIG)
  require CONFIG
end

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key

  config.vm.box = "phusion-open-ubuntu-14.04-amd64"
  config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end


  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name

        # Install Docker
      docker_cmd = "wget http://get.docker.io/ubuntu/pool/main/l/lxc-docker-1.5.0/lxc-docker-1.5.0_1.5.0_amd64.deb ;" \
        "dpkg -i lxc-docker-1.5.0_1.5.0_amd64.deb ;"
          # Add vagrant user to the docker group
      docker_cmd << "usermod -a -G docker vagrant; "
      config.vm.provision :shell, :inline => docker_cmd

      # Install Docker
      swarm_cmd = "wget https://github.com/docker/swarm/releases/download/v0.1.0-rc2/docker-swarm_linux-amd64 ;" \
        "mv docker-swarm_linux-amd64 /bin/swarm ;"
        # Add vagrant user to the docker group
      swarm_cmd << "usermod -a -G docker vagrant; "
      config.vm.provision :shell, :inline => swarm_cmd




      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
      end

      ip = "172.17.8.#{i+99}"
      config.vm.network :private_network, ip: ip

      # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
      #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

    end
  end
end
