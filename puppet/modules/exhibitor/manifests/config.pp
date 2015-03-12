# Class: exhibitor::config
#
class exhibitor::config (
  $properties  = $exhibitor::properties,
  $defaults    = $exhibitor::defaults,
  $user        = $exhibitor::user,
  $group       = $exhibitor::group,
  $install_dir = $exhibitor::install_dir,
  $s3_bucket   = $exhibitor::s3_bucket,
  $s3_prefix   = $exhibitor::s3_prefix,
  $access_key  = $exhibitor::aws_access_key_id,
  $secret_key  = $exhibitor::aws_secret_key,
) inherits exhibitor::params {

  $merged_properties = merge($exhibitor::params::properties, $properties)
  $merged_defaults = merge($exhibitor::params::defaults, $defaults)

  file { "${install_dir}/exhibitor.properties":
    ensure  => file,
    content => template('exhibitor/exhibitor.properties.erb'),
    owner   => $user,
    group   => $group,
  }

  file { "${install_dir}/defaults.conf":
    ensure  => file,
    content => template('exhibitor/defaults.conf.erb'),
    owner   => $user,
    group   => $group,
  }

  if !empty($access_key) and !empty($secret_key) {
    file { "${install_dir}/credentials.properties":
      ensure  => file,
      content => template('exhibitor/credentials.properties.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0600',
    }
  }
}
