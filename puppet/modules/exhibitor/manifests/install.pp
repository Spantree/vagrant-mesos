# Class: exhibitor::install
#
class exhibitor::install (
  $version = $exhibitor::version,
  $build_dir = '/usr/local/src/exhibitor',
  $install_dir = $exhibitor::install_dir,
  $user = $exhibitor::user,
  $group = $exhibitor::group,

) {
  # set path for Exec globally
  Exec {
    path => [
      '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/opt/gradle/bin'
    ],
  }

  if(!defined(Class['gradle'])) {
    class { 'gradle':
      version => '2.2.1'
    }
  }

  file { $build_dir:
    ensure => directory
  }

  file { $install_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file { "${build_dir}/build.gradle":
    ensure  => file,
    content => template('exhibitor/build.gradle.erb'),
    require => File[$build_dir],
  }

  exec { 'build-exhibitor':
    command => 'gradle --no-daemon jar',
    cwd     => $build_dir,
    require => [
      File["${build_dir}/build.gradle"],
      Class['gradle'],
    ]
  }

  file { "${install_dir}/exhibitor.jar":
    ensure  => file,
    source  => "${build_dir}/build/libs/exhibitor-${version}.jar",
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Exec['build-exhibitor'],
  }

}
