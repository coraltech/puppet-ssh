# Class: ssh
#
#   This module manages the SSH service.
#
#   Adrian Webb <adrian.webb@coraltech.net>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters: (see <examples/params.json> for Hiera configurations)
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

  $package                     = $ssh::params::package,
  $package_ensure              = $ssh::params::package_ensure,
  $service                     = $ssh::params::service,
  $service_ensure              = $ssh::params::service_ensure,
  $dev_packages                = $ssh::params::dev_packages,
  $dev_ensure                  = $ssh::params::dev_ensure,
  $extra_packages              = $ssh::params::extra_packages,
  $extra_ensure                = $ssh::params::extra_ensure,
  $init_bin                    = $ssh::params::init_bin,
  $config_file                 = $ssh::params::config_file,
  $config_template             = $ssh::params::config_template,
  $configure_firewall          = $ssh::params::configure_firewall,
  $port                        = $ssh::params::port,
  $allow_root_login            = $ssh::params::allow_root_login,
  $allow_password_auth         = $ssh::params::allow_password_auth,
  $permit_empty_passwords      = $ssh::params::permit_empty_passwords,
  $users                       = $ssh::params::users,
  $user_groups                 = $ssh::params::user_groups,

) inherits ssh::params {

  #-----------------------------------------------------------------------------
  # Installation

  package { 'ssh':
    name   => $package,
    ensure => $package_ensure,
  }

  if ! empty($dev_packages) {
    package { 'ssh-dev-packages':
      name    => $dev_packages,
      ensure  => $dev_ensure,
      require => Package['ssh'],
    }
  }

  if ! empty($extra_packages) {
    package { 'ssh-extra-packages':
      name    => $extra_packages,
      ensure  => $extra_ensure,
      require => Package['ssh'],
    }
  }

  #-----------------------------------------------------------------------------
  # Configuration

  file { 'ssh-config-file':
    path     => $sshd_config_file,
    owner    => "root",
    group    => "root",
    mode     => '0644',
    content  => template($sshd_config_template),
    require  => Package['ssh'],
  }

  exec { "reload-ssh":
    command     => "${init_bin} reload",
    refreshonly => true,
    subscribe   => File['ssh-config-file']
  }

  if $configure_firewall == 'true' and $port > 0 {
    firewall { "150 INPUT Allow new SSH connections":
      action  => accept,
      chain   => 'INPUT',
      state   => 'NEW',
      proto   => 'tcp',
      dport   => $port,
      require => Package['ssh'],
    }
  }

  #-----------------------------------------------------------------------------
  # Services

  service { 'ssh':
    name    => $service,
    ensure  => $service_ensure,
    enable  => true,
    require => Package['ssh'],
  }
}
