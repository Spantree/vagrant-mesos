node default {

  class { 'apt':
    apt_update_frequency => 'reluctantly',
  }

  class { 'mesos_spantree::master':
    zookeeper => 'zk://zk1.mesos.vagrant:2181/mesos',
  }

}
