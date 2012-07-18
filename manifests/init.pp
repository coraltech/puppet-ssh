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

  $package                     = $ssh::params::os_openssh_package,
  $package_ensure              = $ssh::params::openssh_package_ensure,
  $service                     = $ssh::params::os_openssh_service,
  $service_ensure              = $ssh::params::openssh_service_ensure,
  $libcurl_openssl_dev_package = $ssh::params::os_libcurl_openssl_dev_package,
  $libcurl_openssl_dev_ensure  = $ssh::params::libcurl_openssl_dev_ensure,
  $ssh_import_id_package       = $ssh::params::os_ssh_import_id_package,
  $ssh_import_id_ensure        = $ssh::params::ssh_import_id_ensure,
  $configure_firewall          = $ssh::params::configure_firewall,
  $port                        = $ssh::params::port,
  $allow_root_login            = $ssh::params::allow_root_login,
  $allow_password_auth         = $ssh::params::allow_password_auth,
  $permit_empty_passwords      = $ssh::params::permit_empty_passwords,
  $users                       = $ssh::params::users,
  $user_groups                 = $ssh::params::user_groups,
  $sshd_config_file            = $ssh::params::os_sshd_config_file,
  $init_bin                    = $ssh::params::os_init_bin,
  $sshd_config_template        = $ssh::params::os_sshd_config_template,

) inherits ssh::params {

  #-----------------------------------------------------------------------------
  # Installation

  if ! ( $package and $package_ensure ) {
    fail('Open SSH version must be defined')
  }
  package { 'openssh-server':
    name   => $package,
    ensure => $package_ensure,
  }

  if ! ( $libcurl_openssl_dev_package and $libcurl_openssl_dev_ensure ) {
    fail('Libcurl Open SSL dev version must be defined')
  }
  package { 'libcurl4-openssl-dev':
    name    => $libcurl_openssl_dev_package,
    ensure  => $libcurl_openssl_dev_ensure,
    require => Package['openssh-server'],
  }

  if $ssh_import_id_package and $ssh_import_id_ensure {
    package { 'ssh-import-id':
      name    => $ssh_import_id_package,
      ensure  => $ssh_import_id_ensure,
      require => Package['openssh-server'],
    }
  }

  #-----------------------------------------------------------------------------
  # Configuration

  if ! ( $sshd_config_file and $init_bin ) {
    fail('SSH configuration file and init script must be defined')
  }
  file { 'sshd-config-file':
    path     => $sshd_config_file,
    owner    => "root",
    group    => "root",
    mode     => 644,
    content  => template($sshd_config_template),
    require  => Package['openssh-server'],
  }

  exec { "reload-ssh":
    command     => "${init_bin} reload",
    refreshonly => true,
    subscribe   => File['sshd-config-file']
  }

  if $configure_firewall == 'true' and $port > 0 {
    firewall { "150 INPUT Allow new SSH connections":
      action  => accept,
      chain   => 'INPUT',
      state   => 'NEW',
      proto   => 'tcp',
      dport   => $port,
      require => Package['openssh-server'],
    }
  }

  #-----------------------------------------------------------------------------
  # Services

  service { 'ssh':
    name    => $service,
    ensure  => $service_ensure,
    enable  => true,
    require => Package['openssh-server'],
  }
}
