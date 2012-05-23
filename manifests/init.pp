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
#   $port        = 22
#   $user_groups = [ 'admin' ]
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
class ssh ( $port = 22, $user_groups = [ 'admin' ] ) {

  include ssh::params

  #-----------------------------------------------------------------------------

  if $port > 0 {
    class { 'ssh::firewall': port => $port }
  }

  #-----------------------------------------------------------------------------
  # Install

  if ! $ssh::params::open_ssh_server_version {
    fail('Open SSH version must be defined')
  }
  package { 'openssh-server':
    ensure => $ssh::params::open_ssh_server_version,
  }

  if ! $ssh::params::libcurl4_openssl_dev_version {
    fail('Libcurl Open SSL dev version must be defined')
  }
  package { 'libcurl4-openssl-dev':
    ensure => $ssh::params::libcurl4_openssl_dev_version,
  }

  if $ssh::params::ssh_import_id_version {
    package { 'ssh-import-id':
      ensure => $ssh::params::ssh_import_id_version,
    }
  }

  #-----------------------------------------------------------------------------
  # Configure

  if ! ( $ssh::params::sshd_config or $ssh::params::ssh_init_script ) {
    fail('SSH configuration file and init script must be defined')
  }
  file { $ssh::params::sshd_config:
    owner    => "root",
    group    => "root",
    mode     => 644,
    content  => template('ssh/sshd_config.erb'),
  }

  exec { "reload-ssh":
    command     => "${ssh::params::ssh_init_script} reload",
    refreshonly => true,
    subscribe   => File[$ssh::params::sshd_config]
  }

  #-----------------------------------------------------------------------------
  # Manage

  service {
    'ssh':
      enable    => true,
      ensure    => running,
      subscribe => Package['openssh-server'];
  }
}
