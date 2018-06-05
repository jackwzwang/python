#avoiding_circular_dependencies.pp

file { '/etc/haproxy':
  ensure => 'directory',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
}
file { '/etc/haproxy/haproxy.cfg':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
}
service { 'haproxy':
  ensure  => 'running',
  require => File['/etc/haproxy/haproxy.cfg'],
  before  => File['/etc/haproxy'],
}



#control_structures.pp
if 'mail_lda' in $needed_services {
  service { 'dovecot': enable => true }
} else {
  service { 'dovecot': enable => false }
}



#control_structures2.pp
case $role {
  'imap_server': {
    package { 'dovecot': ensure => 'installed' }
    service { 'dovecot': ensure => 'running' }
  }
  /_webserver$/: {
    service { [ 'apache', 'ssh' ]: ensure => 'running' }
  }
  default: {
    service { 'ssh': ensure => running }
  }
}



#control_structures3.pp
case $role {
  Array: {
    include $role[0]
  }
  String: {
    include $role
  }
  default: {
    notify { 'This nodes $role variable is neither an Array nor a String':}
  }
}



#control_structures4.pp
package { 'dovecot':
  ensure  => $role ? {
    'imap_server' => 'installed',
    /desktop$/    => 'purged',
    default       => 'removed',
  },
}



#control_structures5.pp
package { 'dovecot':
  ensure => $role ? {
    Boolean => 'installed',
    String  => 'purged',
    default => 'removed',
  },
}



#core_resource_types.pp
file { '/etc/modules':
  ensure  => file,
  content => "# Managed by Puppet!\n\ndrbd\n",
}


#core_resource_types10.pp
cron { 'clean-files':
  ensure      => present,
  user        => 'root',
  command     => '/usr/local/bin/clean-files',
  minute      => '1',
  hour        => '3',
  weekday     => [ '2', '6' ],
  environment => 'MAILTO=felix@example.net',
}



#core_resource_types11.pp
mount { '/media/gluster-data':
  ensure  => 'mounted',
  device  => 'gluster01:/data',
  fstype  => 'glusterfs',
  options => 'defaults,_netdev',
  dump    => 0,
  pass    => 0,
}



#core_resource_types2.pp
file { '/etc/apache2/sites-enabled/001-puppet-lore.org':
  ensure => 'link',
  target => '../sites-available/puppet-lore.org',
}



#core_resource_types3.pp
file { '../demo.txt':
  ensure => file,
}


#core_resource_types4.pp
package { 'haproxy':
  ensure   => present,
  provider => 'dpkg',
  source   => '/opt/packages/haproxy-1.5.1_amd64.dpkg',
}



#core_resource_types5.pp
service { 'count-logins':
  provider    => 'base',
  ensure      => 'running',
  enable      => true,
  binary      => '/usr/local/bin/cnt-logins',
  start       => '/usr/local/bin/cnt-logins –daemonize',
  has_status  => true,
  has_restart => true,
  subscribe   => File['/usr/local/bin/cnt-logins'],
}


#core_resource_types6.pp
group { 'proxy-admins':
  ensure => present,
  gid    => 4002,
}
user { 'john':
  ensure     => present,
  uid        => 2014,
  home       => '/home/john',
  managehome => true, # <- adds -m to useradd
  gid        => 1000,
  shell      => '/bin/zsh',
  groups     => [ 'proxy-admins' ],
}


#core_resource_types7.pp
exec { 'tar cjf /opt/packages/homebrewn-3.2.tar.bz2':
  cwd     => '/opt',
  path    => '/bin:/usr/bin',
  creates => '/opt/homebrewn-3.2',
}



#core_resource_types8.pp
exec { 'perl -MCPAN -e "install YAML"':
  path   => '/bin:/usr/bin',
  unless => 'cpan -l | grep -qP ^YAML\\b',
}



#core_resource_types9.pp
exec { 'apt-get update':
  path        => '/bin:/usr/bin',
  subscribe   => File['/etc/apt/sources.list.d/jenkins.list'],
  refreshonly => true,
}



#declaring_dependencies.pp
package { 'haproxy':
  ensure => 'installed',
}
->
file { '/etc/haproxy/haproxy.cfg':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
}
->  
service {'haproxy':
  ensure =>  'running',
}



#declaring_dependencies2.pp
package { 'haproxy':
  ensure => 'installed',
}
file {'/etc/haproxy/haproxy.cfg':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  source  => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
  require => Package['haproxy'],
}
service {'haproxy':
  ensure  => 'running',
  require => File['/etc/haproxy/haproxy.cfg'],
}



#declaring_dependencies3.pp
package { 'haproxy':
  ensure => 'installed',
  before => File['/etc/haproxy/haproxy.cfg'],
}
file { '/etc/haproxy/haproxy.cfg':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
  before => Service['haproxy'],
}
service { 'haproxy':
  ensure => 'running',
}



#declaring_dependencies4.pp
file { '/etc/apache2/apache2.conf':
  ensure => file,
  before => Service['apache2'],
}
file { '/etc/apache2/httpd.conf':
  ensure => file,
  before => Service['apache2'],
}
service { 'apache2':
  ensure => running,
  enable => true,
}



#declaring_dependencies5.pp
file { '/etc/apache2/apache2.conf':
  ensure => file,
}
file { '/etc/apache2/httpd.conf':
  ensure => file,
}
service { 'apache2':
  ensure  => running,
  enable  => true,
  require => [
    File['/etc/apache2/apache2.conf'],
    File['/etc/apache2/httpd.conf'],
  ],
}



#declaring_dependencies6.pp
if $os_family == 'Debian' {
  file { '/etc/apt/preferences.d/example.net.prefs':
    content => '...',
    before  => Package['apache2'],
  }
}
package { 'apache2':
  ensure => 'installed',
}



#error_propagation.pp
file { '/etc/haproxy/haproxy.cfg':
  ensure => file,
  source => 'puppet:///modules/haproxy/etc/haproxy.cfg',
}



#hello_world.pp
# hello_world.pp
notify { 'Hello, world!':
}


#order_execution.pp
package { 'haproxy':
  ensure => 'installed',
}
file {'/etc/haproxy/haproxy.cfg':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
}
service { 'haproxy':
  ensure => 'running',
}



#puppet_service.pp
# puppet_service.pp
service { 'puppet':
  ensure => 'stopped',
  enable => false,
}



#puppet_service_provider.pp
service { 'puppet':
  ensure   => 'stopped',
  enable   => false,
  provider => 'upstart',
}



#resource_interaction.pp
file { '/etc/haproxy/haproxy.cfg':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  source  => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
  require => Package['haproxy'],
}
service { 'haproxy':
  ensure    => 'running',
  subscribe => File['/etc/haproxy/haproxy.cfg'],
}



#resource_interaction2.pp
file { '/etc/haproxy/haproxy.cfg':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  source  => 'puppet:///modules/haproxy/etc/haproxy/haproxy.cfg',
  require => Package['haproxy'],
  notify  => Service['haproxy'],
}
service { 'haproxy':
  ensure => 'running',
}



#resource_interaction3.pp
file { '/etc/haproxy/haproxy.cfg': ... }
~>
service { 'haproxy': ... }


#using_variables.pp
$download_server = 'img2.example.net'
$url = "https://${download_server}/pkg/example_source.tar.gz"



#variable_in_titles2.pp
$packages = [
  'apache2',
  'libapache2-mod-php5',
  'libapache2-mod-passenger',
]
package { $packages:
  ensure => 'installed'
}



#variable_types2.pp
$x = $a_string
$y = $an_array[1]
$z = $a_hash['object']



#variables_in_titles.pp
package { $apache_package:
  ensure => 'installed'
}
