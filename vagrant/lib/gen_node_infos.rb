# -*- mode: ruby -*-
# vi: set ft=ruby :

def gen_node_infos(cluster_yml)

  aws_access_key = ENV['AWS_ACCESS_KEY']
  aws_secret_key = ENV['AWS_SECRET_KEY']

  hostname_suffix = cluster_yml['hostname_suffix']

  zookeeper_node_count = cluster_yml['zk_n']
  mesos_node_count  = cluster_yml['mesos_n']
  slave_node_count  = cluster_yml['slave_n']

  zookeeper_connections = (1..zookeeper_node_count).map do |i|
    "zk#{i}.#{hostname_suffix}:2181"
  end

  zookeeper_servers = (1..zookeeper_node_count).map do |i|
    "#{hostname_suffix}:2888:3888"
  end
  
  zk_infos = (1..zookeeper_node_count).map do |i|
    {
      :hostname => "zk#{i}",
      :fqdn => "zk#{i}.#{hostname_suffix}",
      :ip => cluster_yml['zk_ipbase'] + "#{10+i}",
      :mem => cluster_yml['zk_mem'],
      :cpus => cluster_yml['zk_cpus'],
      :manifest_file => "zk.pp",
      :facts => {
        :zookeeper_servers => zookeeper_servers.join(','),
        :aws_access_key => aws_access_key,
        :aws_secret_key => aws_secret_key,
      }
    }
  end

  mesos_infos = (1..mesos_node_count).map do |i|
    {
      :hostname => "mesos#{i}",
      :fqdn => "mesos#{i}.#{hostname_suffix}",
      :ip => cluster_yml['mesos_ipbase'] + "#{10+i}",
      :mem => cluster_yml['mesos_mem'],
      :cpus => cluster_yml['mesos_cpus'],
      :manifest_file => "mesos.pp",
      :facts => {
        :quorum => (mesos_node_count.to_f / 2).ceil
      }
    }
  end

  slave_infos = (1..slave_node_count).map do |i|
    {
      :hostname => "slave#{i}",
      :fqdn => "slave#{i}.#{hostname_suffix}",
      :ip => cluster_yml['slave_ipbase'] + "#{10+i}",
      :mem => cluster_yml['slave_mem'],
      :cpus => cluster_yml['slave_cpus'],
      :manifest_file => "mesos-slave.pp",
      :facts => {
      }
    }
  end

  return {
    :zk => zk_infos,
    :mesos => mesos_infos,
    :slave => slave_infos,
  }
end
