# Class: exhibitor
# Installs and configures exhibitor
class exhibitor(
  $version           = $exhibitor::params::version,
  $zk_version        = $exhibitor::params::zk_version,
  $zk_mirror         = $exhibitor::params::zk_mirror,
  $install_dir       = $exhibitor::params::install_dir,
  $zk_home_dir       = $exhibitor::params::zk_home_dir,
  $zk_log_dir        = $exhibitor::params::zk_log_dir,
  $zk_data_dir       = $exhibitor::params::zk_data_dir,
  $properties        = $exhibitor::params::properties,
  $defaults          = $exhibitor::params::defaults,
  $user              = $exhibitor::params::user,
  $group             = $exhibitor::params::group,
  $config_type       = 'file',
  $s3_bucket         = '',
  $s3_prefix         = 'zk',
  $aws_access_key_id = '',
  $aws_secret_key    = '',
  $aws_region        = 'us-east-1',
) inherits exhibitor::params {

  class { 'exhibitor::users': }
  class { 'exhibitor::zookeeper':
    require => Class['exhibitor::users'],
  }
  class { 'exhibitor::install':
    require => Class['exhibitor::zookeeper'],
  }
  class { 'exhibitor::config':
    require => Class['exhibitor::install'],
  }
  class { 'exhibitor::service':
    require => Class['exhibitor::config'],
  }
}
