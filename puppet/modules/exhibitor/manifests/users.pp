# Class: exhibitor::users
class exhibitor::users(
  $user = $exhibitor::user,
  $group = $exhibitor::group,
) {

  group { $group:
    ensure => present,
    system => true,
  }

  user { $user:
    ensure  => present,
    system  => true,
    groups  => [$group],
    require => Group[$group],
  }
}
