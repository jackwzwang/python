#anchor_pattern.pp
class example_app {
  anchor { 'example_app::begin':
    notify => Class['example_app_config'],
  }
  include example_app_config
  anchor { 'example_app::end':
    require => Class['example_app_config'],
  }
}



#cavecats_of_parameterized_classes.pp
class { 'apache::config': }
include apache::config


#cavecats_of_parameterized_classes2.pp
include apache::config
class { 'apache::config': }


#classes_with_parameters.pp
class apache::config(Integer $max_clients=100) {
  file { '/etc/apache2/conf.d/max_clients.conf':
    content => "MaxClients ${max_clients}\n",
  }
}



#classes_with_parameters2.pp
class { 'apache::config':
  max_clients => 120,
}


#component_classes.pp
package { 'netcat':
  ensure => 'installed',
}


#component_classes2.pp
class netcat {
  package { 'netcat':
    ensure => 'installed',
  }
}


#component_classes3.pp
class scripts_directory {
  file { [ '/opt/company/', '/opt/company/bin' ]:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}



#comprehensive_classes.pp
class monolithic_security {
  package { [ 'iptables', 'rkhunter', 'postfix' ]:
    ensure => 'installed',
  }
  cron { 'run-rkhunter':
    ...
  }
  file { '/etc/init.d/iptables-firewall':
    source => ...,
    mode => 755,
  }
  file { '/etc/postfix/main.cf':
    ensure => 'file',
    content => ...,
  }
  service { [ 'postfix', 'iptables-firewall' ]:
    ensure => 'running',
    enable => true,
  }
}

class divided_security {
  include iptables_firewall
  include rkhunter
  include postfix
}



#contain_function.pp
class apache {
  contain apache::service
  contain apache::package
  contain apache::config
}


#creating_defined_types.pp
define virtual_host(
  String $content,
  String[3,3] $priority = '050'
){
  file { "/etc/apache2/sites-available/${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content
  }
  file { "/etc/apache2/sites-enabled/${priority}-${name}":
    ensure => 'link',
    target => "../sites-available/${name}";
  }
}



#declaring_classes.pp
include apache


#declaring_defined_types.pp
virtual_host { 'example.net':
  content => file('apache/vhosts/example.net'),
}
virtual_host{ 'fallback':
  priority => '999',
  content  => file('apache/vhosts/fallback'),
}


#declaring_defined_types_semicolon.pp
virtual_host {
  'example.net':
    content => 'foo';
  'fallback':
    priority => '999',
    content  => ...,
}


#defined_types_as_macros.pp
file { '/etc/example_app/conf.d.enabled/england':
  ensure => 'link',
  target => '../conf.d.available/england',
}
file { '/etc/example_app/conf.d.enabled/ireland':
  ensure => 'link',
  target => '../conf.d.available/ireland',
}
file { '/etc/example_app/conf.d.enabled/germany':
  ensure => 'link',
  target => '../conf.d.available/germany',
  ...
}



#defined_types_as_macros2.pp
define example_app_config {
  file { "/etc/example_app/conf.d.enabled/${title}":
    ensure => 'link',
    target => "../conf.d.available/${title}",
  }
}



#defined_types_as_macros3.pp
example_app_config {'england': }
example_app_config {'ireland': }
example_app_config {'germany': }
...



#defined_types_as_macros4.pp
example_app_config { [ 'england', 'ireland', 'germany', ... ]:
}



#defined_types_as_wrappers.pp
define module_file(
  String $module
) {
  file { $title:
    source => "puppet:///modules/${module}/${title}",
  }
}



#defined_types_as_wrappers2.pp
module_file { '/etc/ntpd.conf':
  module => 'ntp',
}



#defined_types_as_wrappers3.pp
file { '/etc/ntpd.conf':
  source => 'puppet:///modules/ntp/etc/ntpd.conf',
}


#defined_types_as_wrappers4.pp
define module_file(
  String           $module,
  Optional[String] $mode = undef,
) {
  if $mode != undef {
    File { mode => $mode, }
  }
  file { $title:
    source => "puppet:///modules/${module}/${title}",
  }
}



#defining_classes.pp
class apache {
  package { 'apache2':
    ensure => present,
  }
  file { '/etc/apache2/apache2.conf':
    ensure => 'file',
    source => 'puppet:///modules/apache/etc/apache2/apache2.conf',
  }
  service { 'apache2':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/apache2/apache2.conf'],
  }
}



#exploiting_arrays_in_defined_types.pp
define example_app_config (
  Array $regions = [],
){
  file { "/etc/example_app/conf.d.enabled/${title}":
    ensure => link,
    target => "../conf.d.available/${title}",
  }
  # to do: add functionality for $region
}


#exploiting_arrays_in_defined_types2.pp
example_app_config { 'england':
  regions => [ 'South East', 'London' ],
}
example_app_config { 'ireland':
  regions => [ 'Connacht', 'Ulster' ],
}
example_app_config { 'germany':
  regions => [ 'Berlin', 'Bayern', 'Hamburg' ],
}
...



#exploiting_arrays_in_defined_types3.pp
file { $regions:
  path   => "/etc/example_app/conf.d.enabled/${title}/regions/${title}",
  ensure => 'link',
  target => "../../regions.available/${title}";
}



#exploiting_arrays_in_defined_types4.pp
define example_app_region(String $country) {
  file { "/etc/example_app/conf.d.enabled/${country}/regions/${title}":
    ensure => 'link',
    target => "../../regions.available/${title}",
  }
}


#exploiting_arrays_in_defined_types5.pp
define example_app_config(Array $regions = []) {
  file { "/etc/example_app/conf.d.enabled/${title}":
    ensure => 'link',
    target => "../conf.d.available/${title}",
  }
  example_app_region { $regions:
    country => $title,
  }
}



#including_classes_from_defined_types.pp
file { [ '/etc/example_app', '/etc/example_app/config.d.enabled' ]:
  ensure => 'directory',
}


#including_classes_from_defined_types2.pp
define example_app_config(Array $regions = []) {
  include example_app_config_directories
  ...
}



#iterator_in_defined_types.pp
[ 'england', 'ireland', 'germany' ].each |$country| {
  file { "/etc/example_app/conf.d.enabled/${country}":
    ensure => 'link',
    target => "../conf.d.available/${country}",
  }
}



#iterator_in_defined_types2.pp
$region_data = {
  'england' => [ 'South East', 'London' ],
  'ireland' => [ 'Connacht', 'Ulster' ],
  'germany' => [ 'Berlin', 'Bayern', 'Hamburg' ],
}
$region_data.each |$country, $region_array| {
  $region_array.each |$region| {
    file { "/etc/example_app/conf.d.enabled/${country}/regions/${region}":
      ensure => link,
      target => "../../regions.available/${region}",
    }
  }
}



#multiple_reosurces_in_defines.pp
define user_with_key(
  String           $key,
  Optional[String] $uid   = undef,
  String           $group = 'users'
){
  user { $title:
    ensure     => present,
    gid        => $group,
    uid        => $uid,
    managehome => true,
  }
  ssh_authorized_key { "key for ${title}":
    ensure => present,
    user   => $title,
    type   => 'rsa',
    key    => $key,
  }
}



#node_classification.pp
node 'webserver01' {
  include apache
}



#ordering_containers.pp
include firewall
include loadbalancing
Class['loadbalancing'] -> Class['firewall']


#ordering_containers_limitations.pp
class apache {
  include apache::service
  include apache::package
  include apache::config
}
file { '/etc/apache2/conf.d/passwords.conf':
  source  => '...',
  require => Class['apache'],
}



#ordering_containers_limitations2.pp
file { '/etc/apache2/conf.d/passwords.conf':
  source  => '...',
  require => Class['apache'],
  notify  => Class['apache'],
}



#ordering_containers_limitations3.pp
file { '/etc/apache2/conf.d/passwords.conf':
  source  => '...',
  require => Class['apache::package'],
  notify  => Class['apache::service'],
}



#ordering_containers_limitations4.pp
class apache {
  virtual_host { 'example.net': ... }
  ...
}



#passing_events_between_classes_and_defined_types.pp
file { '/var/lib/apache2/sample-module/data01.bin':
  source => '...',
  notify => Class['apache'],
}
service { 'apache-logwatch':
  enable    => true,
  subscribe => Class['apache'],
}



#passing_events_between_classes_and_defined_types2.pp
$active_countries = [ 'England', 'Ireland', 'Germany' ]
service { 'example-app':
  enable    => true,
  subscribe => Symlink[$active_countries],
}



#passing_events_between_classes_and_defined_types3.pp
symlink { [ 'England', 'Ireland', 'Germany' ]:
  notify => Service['example-app'],
}



#passing_events_between_classes_and_defined_types4.pp
file { '/etc/example_app/main.conf':
  source => '...',
  notify => Protected_service['example-app'],
}



#preferring_include.pp
class apache {
  class { 'apache::service': }
  class { 'apache::package': }
  class { 'apache::config': }
}



#uniqueness_of_defined_types.pp
virtual_host { 'wordpress':
  content  => file(...),
  priority => '011',
}
virtual_host { 'wordpress':
  content  => '# Dummy vhost',
  priority => '600',
}


