#file_source.pp
file { '/usr/local/etc/my_app.ini':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  source => 'puppet:///modules/my_app/usr/local/etc/my_app.ini',
}



#puppet_cron.pp
service { 'puppet': enable => false, }
cron { 'puppet-agent-run':
  user    => 'root',
  command => 'puppet agent --no-daemonize --onetime --logdest=syslog',
  minute  => fqdn_rand(60),
  hour    => absent,
}



