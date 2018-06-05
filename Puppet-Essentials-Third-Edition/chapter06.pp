#06_template_as_file_content.pp
file { '/etc/apache2/conf.d/cacti.conf':
  content => epp('cacti/apache/cacti.conf.epp'),
}


#06_template_in_defined_type.pp
define logrotate::conf(
  String  $pattern,
  Integer $max_days = 7,
  Array   $options  = [],
){
file { "/etc/logrotate.d/${title}":
  ensure  => file,
  mode    => '0644',
  content => epp('logrotate/config-snippet.epp',
    {
      'pattern'  => $pattern,
      'max_days' => $max_days,
      'options'  => $options,
    },),
  }
}



#07_inline_epp.pp
$comma_seperated_list = inline_epp('<%= $my_class::my_array * "," %>')



#08_file_line.pp
file_line { 'user admin proxy':
  ensure => present,
  path   => '/home/admin/.bashrc',
  line   => 'export http_proxy=http://proxy.domain.com:3127',
}



#09_file_line2.pp
file { '/home/admin/.bashrc':
  ensure => file,
  owner  => 'admin',
  group  => 'admin',
  mode   => '0644',
}



#10_ini_setting.pp
ini_setting { 'puppet agent report':
  ensure  => present,
  path    => '/etc/puppetlabs/puppet/puppet.conf',
  section => 'agent',
  setting => 'report',
  value   => 'true',
}



#11_ini_setting2.pp
ini_setting { 'ssh config host default':
  ensure              => present,
  path                => '/etc/ssh/ssh_config',
  section             => 'Host *',
  section_prefix      => '',
  section_suffix      => '',
  key_value_separator => ' ',
  setting             => 'HashKnownHosts',
  value               => 'true',
}



#12_concat.pp
concat { 'ssh config':
  ensure => present,
  path   => '/etc/ssh/ssh_config',
}



#13_concat2.pp
concat::fragment { 'ssh_config header':
  target  => 'ssh config',
  content => "# Managed by Pupept\n",
  order   => '01',
}
concat::fragment { 'default host':
  target => 'ssh config',
  source => 'puppet:///modules/<modulename>/ssh_config_default host',
  order  => '10',
}



#14_virtual_resources.pp
class yumrepos::team_ninja_stable {
  yumrepo { 'team_ninja_stable':
    ensure => present,
    # ...
  }
}



#15_virtual_resources2.pp
include yumrepos::team_ninja_stable
include yumrepos::team_wizard_experimental
package { 'doombunnies':
  ensure  => installed,
  require => [
    Class['yumrepos::team_ninja_stable'],
    Class['yumrepos::team_wizard_experimental'],
  ],
}



#16_virtual_resources3.pp
class yumrepos::all {
  @yumrepo { 'tem_ninja_stable':
    ensure => present,
    tag    => 'stable',
  }
  @yumrepo { 'team_wizard_experimantel':
    ensure => present,
    tag    => 'experimental',
  }
}



#17_virtual_resources4.pp
realize(Yumrepo['team_ninja_stable'])
realize(Yumrepo['team_wizard_experimental'])
package { 'doombunnies':
  ensure  => installed,
  require => [
    Yumrepo['team_ninja_stable'],
    Yumrepo['team_wizard_experimental'],
  ],
}



#18_tags.pp
file { '/etc/sysctl.conf':
  ensure => file,
  tag    => 'security',
}



#19_virtual_resources5.pp
@user { 'felix':
  ensure => present,
  groups => [ 'power', 'sys' ],
}
User <| groups == 'sys' |>



#20_exported_resources.pp
@@file { 'my-app-psk':
  ensure  => file,
  path    => '/etc/my-app/psk',
  content => 'nwNFgzsn9n3sDfnFANfoinaAEF',
  tag     => 'cluster02',
}



#23_store_exported_resources.pp
include puppetdb 
class { 'puppetdb::master::config':
  puppetdb_server => 'master.example.net',
}



#24_exported_resources2.pp
@@sshkey { $::facts['networking']['fqdn']:
  host_aliases => $::facts['networking']['hostname'],
  key          => $::facts['sshecdsakey'],
  tag          => 'san-nyc'
}




#25_exported_resources3.pp
@@host { $::facts['networking']['fqdn']:
  ip           => $::facts['networking']['ipaddress'],
  host_aliases => [ $::facts['networking']['hostname'] ],
  tag          => 'nyc-site',
}



#26_exported_resources4.pp
class site::ssh {
  # ...actual SSH management...
  @@nagios_service { "${::facts['networking']['fqdn']}-ssh":
    use       => 'ssh_template',
    host_name => $::facts['networking']['fqdn'],
  }
}



#27_exported_resources5.pp
@@firewall { "150 forward port 443 to ${::facts['networking']['hostname']}":
  proto       => 'tcp',
  dport       => '443',
  destination => $public_ip_address,
  jump        => 'DNAT',
  todest      => $::facts['networking']['ipaddress'],
  tag         => 'segment03',
}



#29_set_param_on_collection.pp
User<| title == 'felix' |> {
  uid => '2066'
}



#30_set_param_on_collection2.pp
include cacti
Package<| title == 'cacti' |> { ensure => 'latest' }


#31_resource_default.pp
Mysql_grant {
  options    => ['GRANT'],
  privileges => ['ALL'],
  tables     => '*.*',
}
mysql_grant { 'root':
  ensure => 'present',
  user   => 'root@localhost',
}
mysql_grant { 'apache':
  ensure => 'present',
  user   => 'apache@10.0.1.%',
  tables => 'application.*',
}
mysql_grant { 'wordpress':
  ensure => 'present',
  user   => 'wordpress@10.0.5.1',
  tables => 'wordpress.*',
}
mysql_grant { 'backup':
  ensure     => 'present',
  user       => 'backup@localhost',
  privileges => [ 'SELECT', 'LOCK TABLE' ],
}



#32_resource_default2.pp
class webserver {
  File { owner => 'www-data' }
  include apache, nginx, firewall, logging_client
  file {
    ...
  }
}


#33_avoiding_antipatterns.pp
if defined(File['/etc/motd']) {
  notify { 'This machine has a MotD': }
}



#34_avoiding_antipatterns2.pp
if ! defined(Package['apache2']) {
  package { 'apache2':
    ensure => 'installed',
  }
}



#35_avoiding_antipatterns3.pp
class cacti {
  if !defined(Package['apache2']) {
    package { 'apache2': ensure => 'present' }
  }
}
class postfixadmin {
  if !defined(Package['apache2']) {
    package { 'apache2': ensure => 'latest' }
  }
}



#36_avoiding_antipatterns4.pp
ensure_resource('package', 'apache2', { ensure => 'installed' })


