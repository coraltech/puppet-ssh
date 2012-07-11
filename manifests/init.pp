# Class: ssh
#
#   This module manages the SSH service.
#
#   Adrian Webb <adrian.webb@coraltg.com>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters:
#
#   $port                         = $ssh::params::port,
#   $allow_root_login             = $ssh::params::allow_root_login,
#   $allow_password_auth          = $ssh::params::allow_password_auth,
#   $permit_empty_passwords       = $ssh::params::permit_empty_passwords,
#   $users                        = $ssh::params::users,
#   $user_groups                  = $ssh::params::user_groups,
#   $sshd_config                  = $ssh::params::sshd_config,
#   $ssh_init_script              = $ssh::params::ssh_init_script,
#   $open_ssh_server_version      = $ssh::params::open_ssh_server_version,
#   $libcurl4_openssl_dev_version = $ssh::params::libcurl4_openssl_dev_version,
#   $ssh_import_id_version        = $ssh::params::ssh_import_id_version
#
# Actions:
#
#  Installs, configures, and manages the SSH service.
#
# Requires:
#
# Sample Usage:
#
#   class { 'ssh':
#     port        => 22000,
#     user_groups => [ 'admin', 'git' ]
#   }
#
# [Remember: No empty lines between comments and class definition]
class ssh (

  $port                         = $ssh::params::port,
  $allow_root_login             = $ssh::params::allow_root_login,
  $allow_password_auth          = $ssh::params::allow_password_auth,
  $permit_empty_passwords       = $ssh::params::permit_empty_passwords,
  $users                        = $ssh::params::users,
  $user_groups                  = $ssh::params::user_groups,
  $sshd_config                  = $ssh::params::sshd_config,
  $ssh_init_script              = $ssh::params::ssh_init_script,
  $open_ssh_server_version      = $ssh::params::open_ssh_server_version,
  $libcurl4_openssl_dev_version = $ssh::params::libcurl4_openssl_dev_version,
  $ssh_import_id_version        = $ssh::params::ssh_import_id_version

) inherits ssh::params {

  #-----------------------------------------------------------------------------

  if $port > 0 {
    class { 'ssh::firewall': port => $port }
  }

  #-----------------------------------------------------------------------------
  # Install

  if ! $open_ssh_server_version {
    fail('Open SSH version must be defined')
  }
  package { 'openssh-server':
    ensure => $open_ssh_server_version,
  }

  if ! $libcurl4_openssl_dev_version {
    fail('Libcurl Open SSL dev version must be defined')
  }
  package { 'libcurl4-openssl-dev':
    ensure => $libcurl4_openssl_dev_version,
  }

  if $ssh_import_id_version {
    package { 'ssh-import-id':
      ensure => $ssh_import_id_version,
    }
  }

  #-----------------------------------------------------------------------------
  # Configure

  if ! ( $sshd_config or $ssh_init_script ) {
    fail('SSH configuration file and init script must be defined')
  }
  file { $sshd_config:
    owner    => "root",
    group    => "root",
    mode     => 644,
    content  => template('ssh/sshd_config.erb'),
  }

  exec { "reload-ssh":
    command     => "${ssh_init_script} reload",
    refreshonly => true,
    subscribe   => File[$sshd_config]
  }

  #-----------------------------------------------------------------------------
  # Manage

  service {
    'ssh':
      enable    => true,
      ensure    => running,
      subscribe => Package['openssh-server'],
  }
}
