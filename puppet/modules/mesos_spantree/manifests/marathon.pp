# Class: mesos::marathon
#
class mesos_spantree::marathon(
  $master    = 'localhost:5050',
  $zookeeper_root = 'zk://local:2181',
) {

  if ! tagged('mesos_spantree::common') {
    class { 'mesos_spantree::common': }
  }

  if ! defined(Package['marathon']) {
    package { 'marathon':
      ensure => present,
    }
  }

  upstart::job { 'marathon':
    description   => 'Marathon',
    author        => 'Spantree Technology Group',
    version       => '0.8.0',
    start_on      => 'runlevel [2345]',
    stop_on       => 'runlevel [!2345]',
    respawn       => true,
    respawn_limit => '5 10',
    script        => "
      ulimit -n 65636
      ulimit -s 10240
      ulimit -c unlimited
      exec java -Djava.library.path=/usr/lib -Djava.util.logging.SimpleFormatter.format=%2$s%5$s%6$s%n -Xmx512m -cp /usr/bin/marathon mesosphere.marathon.Main --master ${zookeeper_root}/mesos --zk ${zookeeper_root}/marathon
    ",
    env          => {
      'MESOS_NATIVE_JAVA_LIBRARY' => '/usr/lib/libmesos.so',
    },
    require => Package['marathon'],
  }
}
