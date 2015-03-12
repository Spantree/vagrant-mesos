require 'yaml'
require File.join(File.dirname(__FILE__), 'vagrant/lib/gen_node_infos')

PROJECT_ROOT='/usr/local/src/vagrant-mesos'

base_dir = File.expand_path(File.dirname(__FILE__))
conf = YAML.load_file(File.join(base_dir, "cluster.yml"))
node_infos = gen_node_infos(conf)

exhibitor_url = "http://#{node_infos[:zk][0][:hostname]}:8080"

Vagrant.configure("2") do |config|
  config.vm.box = "spantree/trusty64-puppet-3.7.4-java8"
  config.vm.box_version = ">= 1.0.0"

  config.vm.synced_folder '.', PROJECT_ROOT, :create => 'true'
  config.vm.synced_folder 'puppet', '/usr/local/etc/puppet', :create => 'true'

  config.ssh.username = "vagrant"
  config.ssh.shell = "bash -l"

  config.ssh.keep_alive = true
  config.ssh.forward_agent = false
  config.ssh.forward_x11 = false
  config.vagrant.host = :detect

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = false
    config.cache.enable :apt
    config.cache.enable :generic, {
      "wget" => { cache_dir: "/var/cache/wget" },
    }
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  [
    node_infos[:zk], 
    node_infos[:mesos],
    node_infos[:slave],
  ].flatten.each_with_index do |ninfo, i|
    config.vm.define ninfo[:hostname] do |box|
      facts = {
        :ssh_username => "vagrant",
        :host_environment => "vagrant",
      }

      if(ninfo[:facts])
        facts = facts.merge(ninfo[:facts])
      end

      box.hostmanager.aliases = [ninfo[:hostname]]
      # TODO: Fix this in the base box
      box.vm.provision :shell, :inline => "apt-get update"
      box.vm.provision :shell, :path => "shell/curl-setup.sh", :args => [PROJECT_ROOT, '3.7.8']

      box.vm.provision :shell, :inline => <<-SCRIPT
        mkdir -p /var/lib/exhibitor
        echo "#{exhibitor_url}" > /var/lib/exhibitor/url
      SCRIPT

      box.vm.provider :virtualbox do |vb, override|
        override.vm.hostname = ninfo[:fqdn]
        override.vm.network :private_network, :ip => ninfo[:ip]
        override.vm.provision :hosts

        vb.name = 'mesos-issue-demo-' + ninfo[:hostname]
        vb.customize ["modifyvm", :id, "--memory", ninfo[:mem], "--cpus", ninfo[:cpus]]
      end

      box.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = ninfo[:manifest_file]
        puppet.facter = facts
        puppet.options = [
          "--verbose",
          "--debug",
          "--graph",
          "--modulepath=/etc/puppet/modules:#{PROJECT_ROOT}/puppet/modules",
          "--hiera_config #{PROJECT_ROOT}/hiera.yaml",
          "--templatedir=#{PROJECT_ROOT}/puppet/templates",
        ]
      end
    end
  end
end
