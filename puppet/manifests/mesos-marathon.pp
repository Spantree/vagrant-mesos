node default {

  class { 'apt':
    apt_update_frequency => 'reluctantly',
  }

  class { 'mesos_spantree::marathon':
  }

}
