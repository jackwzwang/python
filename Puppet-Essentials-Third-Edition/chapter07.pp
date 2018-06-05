#bool_algebra_on_strings.pp
class ssh (
  $server = true,
){
  if $server {...}
}



#bool_algebra_on_strings2.pp
include ssh
class { 'ssh': server => 'yes', }


#bool_algebra_on_strings3.pp
class { 'ssh': server => false, }
class { 'ssh': server => '', }


#bool_algebra_on_strings4.pp
class ssh (
  $server = true,
){
  if $server and $server != '' {...}
}



#ca_Server_and_server.pp
ini_setting { 'puppet_ca_server':
  path    => '/etc/puppet/puppet.conf',
  section => 'agent',
  setting => 'ca_server',
  value   => 'puppet4.example.net'
}



#default_data_type.pp
$enable_real = $enable ? {
  Boolean => $enable,
  String  => str2bool($enable),
  Default => fail('Unsupported value for ensure. Expected either bool or string.'),
}



#different_data_types.pp
case $::operatingsystemmajrelease {
  '8': {
    include base::debian::jessie
  }
}



#different_data_types2.pp
if $::operatingsystemmajrelease > 7 {
  include base::debian::jessie
}



#epp_templates3.pp
epp('template/test.epp', {'local_variable' => 'value', 'local_array' => ['value1', 'value2'] })



#epp_templates5.pp
file {'/etc/motd':
  ensure  => file,
  content => inline_epp("Welcome to <%= $::fqdn %>\n")
}



#filter_function.pp
$pkg_array = [ 'libjson', 'libjson-devel', 'libfoo', 'libfoo-devel']
$dev_packages = $pkg_array.filter |$element| {
  $element =~ /devel/
}
notify { "Packages to install: ${dev_packages}": }



#filter_function2.pp
$hash = {
  'jones' => {
    'gid' => 'admin',
  },
  'james' => {
    'gid' => 'devel',
  },
  'john' => {
   'gid' => 'admin',
 },
}
$user_hash = $hash.filter |$key, $value| {
  $value['gid'] =~ /admin/
}
$user_list = keys($user_hash)
notify { "Users to create: ${user_list}": }



#hash.pp
$hash_map = {
  'ben'     => {
    'uid'   => 2203,
    'home'  => '/home/ben',
  },
  'jones'   => {
    'uid'   => 2204,
    'home'  => 'home/jones',
  }
}



#hash2.pp
class users (
  Hash $users
){
  notify { 'Valid Hash': }
}
class { 'users':
  users => $hash_map,
}



#hash2_code.pp
$hash_map = {
  'ben'     => {
    'uid'   => 2203,
    'home'  => '/home/ben',
  },
  'jones'   => {
    'uid'   => 2204,
    'home'  => 'home/jones',
  }
}

class users (
  Hash $users
){
  notify { 'Valid Hash': }
}
class { 'users':
  users => $hash_map,
}



#hash3.pp
class users (
  Hash[
    String,
    Struct[ { 'uid' => Integer,
              'home' => Pattern[ /^\/.*/ ] } ]
  ] $users
){
  notify { 'Valid hash': }
}



#hash3_code.pp
$hash_map = {
  'ben'     => {
    'uid'   => 2203,
    'home'  => '/home/ben',
  },
  'jones'   => {
    'uid'   => 2204,
    'home'  => 'home/jones',
  }
}

class users (
  Hash[
    String,
    Struct[ { 'uid' => Integer,
              'home' => Pattern[ /^\/.*/ ] } ]
  ] $users
){
  notify { 'Valid hash': }
}

class { 'users':
  users => $hash_map,
}



#hash4.pp
define users::user (
  Integer          $uid,
  Pattern[/^\/.*/] $home,
){
  notify { "User: ${title}, UID: ${uid}, HOME: ${home}": }
}



#hash5.pp
class users (
  Hash[String, Hash] $users
){
  $keys = keys($users)
  each($keys) |String $username| {
    users::user{ $username:
      uid  => $users[$username]['uid'],
      home => $users[$username]['home'],
    }
  }
}



#hash5_code.pp
$hash_map = {
  'ben'     => {
    'uid'   => 2203,
    'home'  => '/home/ben',
  },
  'jones'   => {
    'uid'   => 2204,
    'home'  => 'home/jones',
  }
}

define users::user (
  Integer          $uid,
  Pattern[/^\/.*/] $home,
){
  notify { "User: ${title}, UID: ${uid}, HOME: ${home}": }
}

class users (
  Hash[String, Hash] $users
){
  $keys = keys($users)
  each($keys) |String $username| {
    users::user{ $username:
      uid  => $users[$username]['uid'],
      home => $users[$username]['home'],
    }
  }
}

class { 'users':
  users => $hash_map,
}



#hash6.pp
$hash_map = {
  'ben'    => {
    'uid'  => 2203,
    'home' => '/home/ben',
  },
  'jones'  => {
    'uid'  => 2204,
    'home' => '/home/jones',
  }
}



#hash6_code.pp
$hash_map = {
  'ben'    => {
    'uid'  => 2203,
    'home' => '/home/ben',
  },
  'jones'  => {
    'uid'  => 2204,
    'home' => '/home/jones',
  }
}

define users::user (
  Integer          $uid,
  Pattern[/^\/.*/] $home,
){
  notify { "User: ${title}, UID: ${uid}, HOME: ${home}": }
}

class users (
  Hash[String, Hash] $users
){
  $keys = keys($users)
  each($keys) |String $username| {
    users::user{ $username:
      uid  => $users[$username]['uid'],
      home => $users[$username]['home'],
    }
  }
}

class { 'users':
  users => $hash_map,
}



#heredoc.pp
$motd_content = @(EOF)
  This system is managed by Puppet
  local changes will be overwritten by next Puppet run.
EOF


#heredoc2.pp
$motd_content = @("EOF")
  Welcome to ${::fqdn}.
  This system is managed by Puppet version ${::puppetversion}.
  Local changes will be overwritten by the next Puppet run
EOF



#heredoc3.pp
$modt_content = @("EOF"/tn)
Welcome to ${::fqdn}.\n\tThis system is managed by Puppet version ${::puppetversion}.\n\tLocal changes will be overwritten on next Puppet run.
EOF



#heredoc4.pp
$motd_content = @("EOF")
       Welcome to ${::fqdn}.
       This system is managed by Puppet version ${::puppetversion}.
       Local changes will be overwritten on next Puppet run.
       | EOF



#heredoc5.pp
class my_motd (
  Optional[String] $additional_content = undef
){
  $motd_content = @(EOF)
    Welcome to <%= $::fqdn %>.
    This system is managed by Puppet version <%= $::puppetversion %>.
    Local changes will be overwritten on next Puppet run.
    <% if $additional_content != undef { -%>
    <%= $additional_content %>
    <% } -%>
    | EOF
  file { '/etc/motd':
    ensure  => file,
    content => inline_epp($motd_content, { additional_content => $additional_content } ),
  }
}



#lambdas.pp
$packages = ['htop', 'less', 'vim']
each($packages) |String $package| {
  package { $package:
    ensure => latest,
  }
}



#lambdas2.pp
class puppet_symlinks {
  $symlinks = [ 'puppet', 'facter', 'hiera' ]
  puppet_symlinks::symlinks { $symlinks: }
}
define puppet_symlinks::symlinks {
  file { "/usr/local/bin/${title}":
    ensure => link,
    target => "/opt/puppetlabs/bin/${title}",
  }
}



#lambdas3.pp
class puppet_symlinks {
  $symlinks = [ 'puppet', 'facter', 'hiera' ]
  $symlinks.each | String $symlink | {
    file { "/usr/local/bin/${symlink}":
      ensure => link,
      target => "/opt/puppetlabs/bin/${symlink}",
    }
  }
}



#node_inheritance2.pp
class profile::base {
  include security
  include ldap
  include base
}
class profile::webserver {
  class { 'apache': }
  include apache_mod_php
}
class role::webapplication {
  include profile::base
  include profile::webserver
  include profile::webapplication
}
node 'www01.example.net' {
  include role::webapplication
}



#node_inhertiance.pp
node basenode {
  include security
  include ldap
  include base
}
node 'www01.example.net' inherits 'basenode' {
  class { 'apache': }
  include apache::mod::php
  include webapplication
}



#puppet4_functions3.pp
class resolver {
  $localname = resolver()
  notify { "Without argument resolver returns local hostname: ${localname}": }
  $remotename = resolver('puppetlabs.com')
  notify { "With argument puppetlabs.com: ${remotename}": }
  $remoteip = resolver('8.8.8.8')
  notify { "With argument 8.8.8.8: ${remoteip}": }
}



#puppet4_functions5.pp
class resolver {
  $localname = resolver::resolve()
  $remotename = resolver::resolve('puppetlabs.com')
  $remoteip = resolver::resolve('8.8.8.8')
}



#relative_class_names.pp
# in module "mysql"
class mysql {
  # ...
}
# in module "application"
class application::mysql {
  include mysql
}



#relative_class_names2.pp
class application::mysql {
  include ::mysql
}


#server_metrics_grafana.pp
node 'graphite.example.com' {
  include grafanadash::dev
}


#server_metrics_hocon.pp
Hocon_setting {
  path   => '/etc/puppetlabs/puppetserver/conf.d/metrics.conf',
  notify => Service['puppetserver'],
}
hocon_setting {'server metrics server-id':
  ensure  => present,
  setting => 'metrics.server-id',
  value   => 'localhost',
}
hocon_setting {'server metrics reporters graphite':
  ensure  => present,
  setting => 'metrics.registries.puppetserver.reporters.graphite.enabled',
  value   => true,
}
hocon_setting {'server metrics graphite host':
  ensure  => present,
  setting => 'metrics.reporters.graphite.host',
  value   => $graphite_server,
}
hocon_setting {'server metrics graphite port':
  ensure  => present,
  setting => 'metrics.reporters.graphite.port',
  value   => 2003,
}
hocon_setting {'server metrics graphite update interval':
  ensure  => present,
  setting => 'metrics.reporters.graphite.update-interval-seconds',
  value   => 5,
}



#slice_function.pp
$array = [ '1', '2', '3', '4']
$array.slice(2) |$slice| {
  notify { "Slice: ${slice}": }
}



#slice_function2.pp
$hash = {
  'key 1' => {'value11' => '11', 'value12' => '12',},
  'key 2' => {'value21' => '21', 'value22' => '22',},
  'key 3' => {'value31' => '31', 'value32' => '32',},
  'key 4' => {'value41' => '41', 'value42' => '42',},
}
$hash.slice(2) |$hslice| {
  notify { "HSlice: ${hslice}": }
}



#strict_variables.pp
class variables {
  $Local_var = 'capital variable'
  notify { "Local capital var: ${Local_var}": }
}



#strict_variables_output.pp
root@puppetmaster:~/chapter7# puppet apply -e 'include variables'
Error: Illegal variable name, The given name 'Local_var' does not conform to the naming rule /^((::)?[a-z]\w*)*((::)?[a-z_]\w*)$/ at /etc/puppetlabs/code/environments/production/modules/variables/manifests/init.pp:2:3 on node puppetmaster.example.net


#type_conversion.pp
$ssh_port = '22'
$ssh_port_integer = 0 + $ssh_port


#type_declaration.pp
# stlib/types/absolutepath.pp
type Stdlib::Absolutepath = Variant[Stdlib::Windowspath, Stdlib::Unixpath]


#type_declaration2.pp
#firewall/types/ipaddress.pp
type Firewall::Ipaddress = Variant[Firewall::Ipv4, Firewall::Ipv6]



#type_system.pp
class ssh (
  $server = true,
){
  if $server {
    include ssh::server
  }
}



#type_system2.pp
class { 'ssh':
  server => 'false',
}



#type_system3.pp
class ssh (
  $server = true,
){
  validate_bool($server)
  if $server {
    include ssh::server
  }
}



#type_system4.pp
class ssh (
  Boolean $server = true,
){
  if $server {
    include ssh::server
  }
}



#type_system4_code.pp
class ssh (
  Boolean $server = true,
){
  if $server {
    include ssh::server
  }
}

class { 'ssh':
  server => 'false',
}



#type_system5.pp
class ssh (
  Boolean                       $server = true,
  Enum['des','3des','blowfish'] $cipher = 'des',
){
  if $server {
    include ssh::server
  }
}



#type_system5_code.pp
class ssh (
  Boolean                       $server = true,
  Enum['des','3des','blowfish'] $cipher = 'des',
){
  if $server {
    include ssh::server
  }
}

class { 'ssh':
  cipher => 'foo',
}



#type_system6.pp
class ssh (
  Boolean                       $server = true,
  Enum['des','3des','blowfish'] $cipher = 'des',
  Optional[Array[String]]       $allowed_users = undef,
){
  if $server {
    include ssh::server
  }
}



#type_system6_code.pp
class ssh (
  Boolean                       $server = true,
  Enum['des','3des','blowfish'] $cipher = 'des',
  Optional[Array[String]]       $allowed_users = undef,
){
  if $server {
    include ssh::server
  }
}

class { 'ssh':
  allowed_users => 'foo',
}


#type_system7.pp
class ssh (
  Boolean                 $server = true,
  Optional[Array[String]] $allowed_users = undef,
  Integer[1,1023]         $sshd_port,
){
  if $server {
    include ssh::server
  }
}



#type_system7_code.pp
class ssh (
  Boolean                 $server = true,
  Optional[Array[String]] $allowed_users = undef,
  Integer[1,1023]         $sshd_port,
){
  if $server {
    include ssh::server
  }
}

class { 'ssh':
  sshd_port => 'ssh',
}




