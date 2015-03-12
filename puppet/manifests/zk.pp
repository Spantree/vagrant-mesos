node default {

  include stdlib

  class { 'java8': }

  class { 'exhibitor':
    config_type => 'file',
    require     => Class['java8'],
  }
}
