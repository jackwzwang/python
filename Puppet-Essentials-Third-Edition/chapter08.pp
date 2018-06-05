#automatically_fetching_data_from_classes5.pp
$nat_port = hiera('site::net::nat_port')
@@firewall { "650 forward port ${nat_port} to ${::fqdn}":
  proto       => 'tcp',
  dport       => $nat_port,
  destination => hiera('site::net::nat_ip'),
  jump        => 'DNAT',
  todest      => $::ipaddress,
  tag         => hiera('site::net::firewall_segment'),
}



#automatically_fetching_data_from_classes7.pp
@@site::maintenance_script {"/usr/local/bin/maint-${::fqdn}":
  address => hiera('site::net::nat_ip'),
  port    => hiera('site::net::nat_port'),
}



#data_in_manifests.pp
class site::mysql_server01 {
  class { 'mysql': server_id => '1', ... }
}
class site::mysql_server02 {
  class { 'mysql': server_id => '2', ... }
}
# ...
class site::mysql_aux01 {
  class { 'mysql': server_id => '101', ... }
}
# and so forth ...



#data_in_manifests2.pp
node 'xndp12-sql09.example.net' {
  class { 'site::mysql_server':
    mysql_server_id => '103',
  }
}



#data_in_manifests3.pp
class site::mysql_server(
  String $mysql_server_id
){
  class { 'mysql':
    server_id => $mysql_server_id,
    ...
  }
}



#data_in_manifests4.pp
$mysql_config_table = {
  'xndp12-sql01.example.net' => {
    server_id   => '1',
    buffer_pool => '12G',
  },
  # ...
}


#data_in_manifests5.pp
class site::mysql_server(
  $config = $mysql_config_table[$::certname]
){
  class { 'mysql':
    server_id => $config['server_id'],
    # ...
  }
}



#data_in_manifests6.pp
$crypt_key_xndp12 = 'xneFGl%23ndfAWLN34a0t9w30.zges4'
$config = {
  'xndp12-stor01.example.net' => { $crypt_key => $crypt_key_xndp12, ... },
  'xndp12-stor02.example.net' => { $crypt_key => $crypt_key_xndp12, ... },
  'xndp12-sql01.example.net'  => { $crypt_key => $crypt_key_xndp12, ... },
   ...
}



#fetching_data_from_classes.pp
$plugins = hiera('reporting::plugins')



#fetching_data_from_classes2.pp
$plugins = hiera('reporting::plugins', [])



#fetching_data_from_classes3.pp
$plugins = hiera('reporting::plugins', [], 'global-overrides')



#fetching_data_from_classes4.pp
@@cacti_device { $::fqdn:
  ip => hiera('snmp_address', $::ipaddress),
}



#fetching_data_from_classes5.pp
$max_threads = hiera('max_threads')
if $max_threads !~ Integer {
  fail "The max_threads value must be an integer number"
}



#fetching_data_from_classes6.pp
define logrotate::config(
  Integer $rotations = hiera('logrotate::rotations', 7)
){
  # regular define code here
}



#fetching_data_from_classes7.pp
logrotate::config { '/var/log/cacti.log': rotations => 12 }



#hash_and_array.pp
if hiera('site::net::nat_ip', false) {
  @@firewall { "200 NAT ports for ${::fqdn}":
    port        => hiera_array('site::net::nat_ports'),
    proto       => 'tcp',
    destination => hiera('site::net::nat_ip'),
    jump        => 'DNAT',
    todest      => $::ipaddress,
  }
}



#hash_and_array2.pp
if hiera('feature_flag_A', undef) != undef { ... }


#include_from_hiera.pp
hiera_include('classes')


#manifest_or_hiera_design.pp
if hiera('use_caching_proxy', false) {
  include nginx
}



#resources_from_data2.pp
$resource_hash.each |$res_title,$attributes| {
  service { $res_title:
    ensure => $attributes['ensure'],
    enable => $attributes['enable'],
  }
}



#resources_from_data3.pp
$resource_hash = hiera('services', {})
create_resources('service', $resource_hash)



