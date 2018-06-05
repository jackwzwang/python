#adding_configuration_items.pp
# .../modules/packt_cacti/manifests/device.pp
define packt_cacti::device (
  $ip,
){
  $cli = '/usr/share/cacti/cli'
  $options = "--description='${title}' --ip='${ip}'"
  exec { "add-cacti-device-${title}":
    command => "${cli}/add_device.php ${options}",
    require => Class['cacti'],
  }
}



#adding_configuration_items2.pp
$search = "sed 1d | cut -f4- | grep -q '^${title}\$'"
exec { "add-cacti-device-${title}":
  command => "${cli}/add_device.php ${options}",
  path    => '/bin:/usr/bin',
  unless  => "${cli}/add_graphs.php --list-hosts | ${search}",
  require => Class[cacti],
}



#adding_configuration_items3.pp
# in manifests/nodes.pp
node 'agent' {
  include packt_cacti
  packt_cacti::device { 'Puppet test agent (Debian 7)':
    ip => $::ipaddress,
  }
}



#allowing_customization.pp
define packt_cacti::device(
  $ip,
  $ping_method='icmp'
){
  $cli = '/usr/share/cacti/cli'
  $base_opt = "--description='${title}' --ip='${ip}'"
  $ping_opt = "--ping_method=${ping_method}"
  $options = "${base_opt} ${ping_opt}"
  $search = "sed 1d | cut -f4- | grep -q '^${title}\$'"
  exec { "add-cacti-device-${title}":
    command => "${cli}/add_device.php ${options}",
    path    => '/bin:/usr/bin',
    unless  => "${cli}/add_graphs.php --list-hosts  | ${search}",
    require => Class[cacti],
  }
}



#custom_functions2.pp
define packt_cacti::device($ip) {
  $cli = '/usr/share/cacti/cli'
  $c_ip = cacti_canonical_ip($ip)
  $options = "--description='${title}' --ip='${c_ip}'"
  exec { "add-cacti-device-${title}":
    command => "${cli}/add_device.php ${options}",
    require => Class[cacti],
  }
}



#dealing_with_complexity2.pp
define packt_cacti::graph(
  $device,
  $graph=$title
){
  $add = '/usr/local/bin/cacti-add-graph'
  $find = '/usr/local/bin/cacti-find-graph'
  exec { "add-graph-${title}-to-${device}":
    command => "${add} '${device}' '${graph}'",
    path    => '/bin:/usr/bin',
    unless  => "${find} '${device}' '${graph}'",
  }
}



#documentation_in_modules.pp
# Class: my_app::firewall
#
# @summary This class adds firewall rules to allow access to my_app.
#
# @example Declaring the class
# include my_app::firewall
#
# @param Parameters: none
class my_app::firewall {
  # class code here
}



#implementing_basic_module_functionality.pp
# .../modules/packt_cacti/manifests/init.pp
class packt_cacti {
  package { 'cacti':
    ensure => installed,
  }
}



#implementing_basic_module_functionality2.pp
node 'agent' {
  include packt_cacti
}



#implementing_basic_module_functionality3.pp
# .../modules/packt_cacti/manifests/redirect.pp
class packt_cacti::redirect {
  file { '/etc/apache2/conf.d/cacti-redirect.conf':
    ensure  => file,
    source  => 'puppet:///modules/packt_cacti/etc/apache2/conf.d/cacti-redirect.conf',
    require => Package['cacti'];
  }
}



#implementing_basic_module_functionality4.pp
$puppet_warning = '# Do not edit - managed by Puppet!'
$line = 'RedirectMatch permanent ^/$ /cacti/'
file { '/etc/apache2/conf.d/cacti-redirect.conf':
  ensure  => file,
  content => "${puppet_warning}\n${line}\n",
}



#implementing_basic_module_functionality5.pp
class packt_cacti(
  $redirect = true,
) {
  if $redirect {
    contain packt_cacti::redirect
  }
  package { 'cacti':
    ensure => installed,
  }
}



#implementing_basic_module_functionality6.pp
class { 'packt_cacti':
  redirect => false,
}



#implementing_basic_module_functionality7.pp
class packt_cacti(
  $redirect = true,
){
  contain packt_cacti::install
  if $redirect {
    contain packt_cacti::redirect
  }
}



#implementing_basic_module_functionality8.pp
# .../modules/packt_cacti/manifests/install.pp
class packt_cacti::install {
  package { 'cacti':
    ensure => 'installed',
  }
}



#implementing_basic_module_functionality9.pp
# .../modules/packt_cacti/manifests/config.pp
class packt_cacti::config {
  file { '/etc/apache2/conf.d/cacti.conf':
    mode   => '0644',
    source => '/usr/share/doc/cacti/cacti.apache.conf',
  }
}



#iplementing_basic_functinality6.pp
node "agent" {
  include cacti
  cacti_device { "Puppet test agent (Debian 7)":
    ensure => present,
    ip     => $::ipaddress,
  }
}



#parts_of_a_module.pp
file { '/etc/ntp.conf':
  source => 'puppet:///modules/ntp/ntp.conf',
}



#portable_os.pp
# .../packt_cacti/manifests/params.pp
class packt_cacti::params {
  case $osfamily {
    'Debian': {
      $cli_path = '/usr/share/cacti/cli'
    }
    'RedHat': {
      $cli_path = '/var/lib/cacti/cli'
    }
    default: {
      fail "the cacti module does not yet support the ${osfamily} platform"
    }
  }
}



#portable_os2.pp
class packt_cacti::install {
  include pack_cacti::params
  file { 'remove_device.php':
    ensure => file,
    path   => "${packt_cacti::params::cli_path}/remove_device.php",
    source => 'puppet:///modules/packt_cacti/cli/remove_device.php',
    mode   => '0755',
  }
}



#portable_os3.pp
class packt_cacti(
  $redirect = $packt_cacti::params::redirect
)inherits packt_cacti::params{
  # ...
}



#removing_unwanted_configuration.pp
file { '/usr/share/cacti/cli/remove_device.php':
  ensure  => file,
  mode    => '0755',
  source  => 'puppet:///modules/packt_cacti/usr/share/cacti/cli/remove_device.php',
  require => Package['cacti'],
}



#removing_unwanted_configuration2.pp
define packt_cacti::device(
  $ensure='present',
  $ip,
  $ping_method='icmp',
){
  $cli = '/usr/share/cacti/cli'
  $search = "sed 1d | cut -f4- | grep -q '^${title}\$'"
  case $ensure {
    'present': {
      # existing cacti::device code goes here
    }
    'absent': {
      $remove = "${cli}/remove_device.php"
      $get_id = "${remove} --list-devices | awk -F'\\t''\$4==\"${title}\" { print \$1 }'"
      exec { "remove-cacti-device-${name}":
        command => "${remove} --device-id=\$( ${get_id})",
        path    => '/bin:/usr/bin',
        onlyif  => "${cli}/add_graphs.php --list-hosts | ${search}",
        require => Class[cacti],
      }
    }
  }
}



#resource_names.pp
exec { '/bin/true': }
# same effect:
exec { 'some custom name': command => '/bin/true' }



#using_native_type.pp
cacti_device { 'eth0':
  ensure      => present,
  ip          => $::ipaddress,
  ping_method => 'icmp',
}



