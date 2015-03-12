# Class: mesos_spantree::master
#
class mesos_spantree::master(
  $zookeeper = 'zk://localhost:2181/mesos',
) {

  if $::ec2_public_ipv4 != undef {
    $mesos_hostname = $::ec2_public_ipv4
  } else {
    $mesos_hostname = $::hostname
  }

  $ip = $::host_environment ? {
    undef => $::ipaddress_eth0,
    'vagrant' => $::ipaddress_eth1,
    default   => $::ipaddress_eth0,
  }

  if ! tagged('mesos_spantree::common') {
    class { 'mesos_spantree::common': }
  }

  ::mesos::property { 'master-hostname':
    value   => $mesos_hostname,
    dir     => '/etc/mesos-master',
    service => Service['mesos-master'],
    file    => 'hostname',
  }

  class { 'mesos::master':
    zookeeper      => $zookeeper,
    listen_address => $ip,
    work_dir       => '/var/lib/mesos',
    options        => {
      quorum => $::quorum,
    },
    env_var        => {
      'MESOS_LOG_DIR' => '/var/log/mesos',
    },
    force_provider => 'none',
  }

  upstart::job { 'mesos-master':
    description   => 'Mesos master',
    author        => 'Spantree Technology Group',
    version       => '0.21.1',
    start_on      => 'runlevel [2345]',
    stop_on       => 'runlevel [!2345]',
    respawn       => true,
    respawn_limit => '5 10',
    pre_start     => '
      sed -i "/^ZK=/c\ZK=zk:\/\/zk1:2181\/mesos" /etc/default/mesos-master
    ',
    script        => '
      ulimit -n 65636
      ulimit -s 10240
      ulimit -c unlimited
      exec /usr/bin/mesos-init-wrapper master
    ',
    env           => {
    },
    require => [
      Class['mesos::master'],
    ],
  }
}
