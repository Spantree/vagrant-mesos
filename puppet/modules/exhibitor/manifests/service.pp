# Class: exhibitor::service
#
class exhibitor::service (
  $config_type = $exhibitor::config_type,
  $s3_bucket   = $exhibitor::s3_bucket,
  $s3_prefix   = $exhibitor::s3_prefix,
  $install_dir = $exhibitor::install_dir,
  $zk_log_dir  = $exhibitor::zk_log_dir,
  $aws_region  = $exhibitor::aws_region,
  $access_key  = $exhibitor::aws_access_key_id,
  $secret_key  = $exhibitor::aws_secret_key,
  $user        = $exhibitor::user,
  $group       = $exhibitor::group,
) {
  $host = '--hostname $(hostname)'
  $cfg = '--defaultconfig /opt/exhibitor/defaults.conf'

  $exhib_bare = "java -jar ${install_dir}/exhibitor.jar"

  if !empty($s3_bucket) and !empty($s3_prefix)
  and !empty($aws_region) and !empty($access_key)
  and !empty($secret_key) and $config_type == 's3' {
    $s3 = "--configtype s3 --s3config ${s3_bucket}:${s3_prefix}"
    $s3creds = '--s3credentials /opt/exhibitor/credentials.properties'
    $region = "--s3region ${exhibitor::aws_region}"
    $cmd = "${exhib_bare} ${cfg} ${s3} ${s3creds} ${region} ${host}"
  }
  else {
    $cmd = "${exhib_bare} -c file ${cfg} ${host}"
  }

  info("Exhibitor command will be ${cmd}")

  case $::lsbdistcodename {
    'trusty', 'precise': {
      class { 'upstart':
        init_dir => '/etc/init',
      }

      upstart::job { 'exhibitor':
        description   => 'The Netflix Exhibitor for Zookeeper management',
        respawn       => true,
        respawn_limit => '5 10',
        chdir         => $exhibitor::install_dir,
        user          => $user,
        group         => $group,
        env           => {
          'ZOO_LOG_DIR' => $zk_log_dir,
        },
        exec          => "${cmd} >> ${zk_log_dir}/exhibitor.log 2>&1",
        require       => Class['exhibitor::config'],
      }
    }
    default: {
      fail("${::operatingsystem} ${::lsbdistcodename} not supported.")
    }
  }
}
