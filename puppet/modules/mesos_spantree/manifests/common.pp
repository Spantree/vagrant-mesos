# Class: mesos_spantree::common
#
class mesos_spantree::common {
  info('in class mesos::common')
  include 'docker'

  class { 'mesos':
    repo => 'mesosphere',
  }
}
