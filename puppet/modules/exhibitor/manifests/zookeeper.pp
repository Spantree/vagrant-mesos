# Class: exhibitor::zookeeper
#
# Super simple zookeeper installer for use with exhibitor
# 
class exhibitor::zookeeper(
  $ensure     = present,
  $version    = $exhibitor::zk_version,
  $home       = $exhibitor::zk_home_dir,
  $log_dir    = $exhibitor::zk_log_dir,
  $data_dir   = $exhibitor::zk_data_dir,
  $user       = $exhibitor::user,
  $group      = $exhibitor::group,
  $mirror_url = $exhibitor::zk_mirror,
) inherits exhibitor::params {

  $url = "${mirror_url}/zookeeper-${version}/zookeeper-${version}.tar.gz"

  archive { "zookeeper-${version}":
    ensure     => present,
    url        => $url,
    src_target => '/usr/local/src',
    target     => '/opt',
  }

  file { $log_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { $data_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { $home:
    ensure  => link,
    target  => "/opt/zookeeper-${version}",
    require => [
      Archive["zookeeper-${version}"],
      File[$log_dir],
      File[$data_dir],
    ],
  }

  exec { 'remove-zookeeper-source':
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    command => "rm -rf /opt/zookeeper-${version}/src",
    require => Archive["zookeeper-${version}"],
  }

  file { "/opt/zookeeper-${version}":
    ensure  => present,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => [
      Exec['remove-zookeeper-source'],
      Archive["zookeeper-${version}"],
      User[$user],
    ]
  }
}
