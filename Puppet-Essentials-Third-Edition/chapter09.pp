#01_profiles.pp
# Class profile::login
#
# manages ssh access
# company policy requires the following settings:
# - forbid root login
# - forbid x11 forwarding
# - allow login based on group (admins)
#
# We have several other settings which are put into our own
# sshd_config template file
#
class profile::login {
  class { 'ssh':
    sshd_x11_forwarding     => false,
    sshd_config_template    => epp('profile/login/sshd_config.epp'),
    sshd_config_allowgroups => ['admins'],
    permit_root_login       => 'no',
  }
}



#02_profiles2.pp
# Class profile::login::secure
#
# Reuses profile::login classes
# adds known_host_file based on template
#
class profile::login::secure {
  include profile::ssh
  file { '/etc/ssh/ssh_known_hosts':
    ensure  => file,
    content => epp('profile/login/ssh_known_hosts.epp'),
  }
}



#03_profiles3.pp
# Class profile::database::mysql
#
# Needs data in hiera:
# - mysql_root_password (String), defaults to 123456
# - mysql_database (Hash)
#
class profile::database::mysql {
  $mysql_root_password = lookup('mysql_root_password', String, 'first', '123456')
  $mysql_database = lookup('mysql_database', Hash, 'deep', '')
  class { 'mysql':
    root_password           => $mysql_root_password,
    remove_default_accounts => true,
  }
  class { 'mysql::bindings':
    php_enable => true,
  }
  $mysql_database.each |$db, $options| {
    mysql::db { $db:
      * => $options,
    }
  }
}


#04_profiles4.pp
# Class profile::scripting::php
#
# uses puppet/php mdoule
# basic installation only
#
class profile::scripting::php {
  include ::php
}



#05_profiles5.pp
# Class profile::apps::phpmyadmin
#
# uses jlondon/phpmyadmin
# configures the application and application vhost
#
class profile::apps::phpmyadmin {
  class { 'phpmyadmin': }
  phpmyadmin::server{ 'default': }
  phpmyadmin::vhost { 'internal.domain.net':
    vhost_enabled => true,
    priority      => '20',
    docroot       => $phpmyadmin::params::doc_path,
    ssl           => true,
  }
}



#06_profiles6.pp
# Class profile::apps::phpmyadmin::db
#
# uses jlondon/phpmyadmin module
# exports the setting for phpmyadmin
#
class profile::apps::phpmyadmin::db {
  @@phpmyadmin::servernode { $::ipaddress:
    server_group => 'default',
  }
}



#07_role.pp
class role::crm_db_control_panel {
  contain profile::login::secure
  contain profile::database::mysql
  contain profile::scripting::php
  contain profile::apps::phpmyadmin::db
  contain profile::apps::phpmyadmin
}



#08_role2.pp
node 'dbcrmmgmt.domain.com' {
  contain role::crm_db_control_panel
}



#15_r10k_webhook.pp
class profile::puppet::master::r10k_webhook {
  class {'r10k::webhook::config':
    enable_ssl      => false,
    use_mcollective => false,
  }
  class {'r10k::webhook':
    use_mcollective => false,
    user            => 'root',
    group           => '0',
  }
}



