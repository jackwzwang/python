#external_facts_from_puppet.pp
file { '/etc/puppetlabs/facter/facts.d/site-facts.yaml':
  ensure => 'file',
  source => 'puppet:///...',
}


#facter_variables.pp
if $::processors['count'] > 4 { ... }


#facter_variables2.pp
file { '/etc/mysql/conf.d/bind-address':
  ensure  => 'file',
  mode    => '0644',
  content => "[mysqld]\nbind-address=${::networking['ip']}\n",
}



#facter_variables3.pp
file { '/etc/my-secret':
  ensure => 'file',
  mode   => '0600',
  owner  => 'root',
  source => "puppet:///modules/secrets/${::clientcert}/key",
}



#facter_variables4.pp
if $::os['name'] != 'Ubuntu' {
  package { 'avahi-daemon':
    ensure => absent
  }
}



#facter_variables5.pp
if $::os['family'] == 'RedHat' {
  $kernel_package = 'kernel'
}



#facter_variables6.pp
if $::os['name'] == 'Debian' {
  if versioncmp($::os['release']['full'], '7.0') >= 0 {
    $ssh_ecdsa_support = true
  }
}



#invalid_resource.pp
cron { 'invalid-resource':
  command => 'apt-get update',
  special => 'midnight',
  weekday => [ '2', '5' ],
}


#resource_providers.pp
package { 'haproxy':
  ensure => 'purged'
}


#resource_with_generic_providers.pp
host { 'puppet':
  ip           => '10.144.12.100',
  host_aliases => [ 'puppet.example.net', 'master' ],
}



