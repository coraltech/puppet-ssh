
class ssh::params {

  #-----------------------------------------------------------------------------
  # General configurations

  if $::hiera_exists {
    $openssh_package_ensure     = hiera('ssh_openssh_package_ensure', $ssh::default::openssh_package_ensure)
    $openssh_service_ensure     = hiera('ssh_openssh_service_ensure', $ssh::default::openssh_service_ensure)
    $libcurl_openssl_dev_ensure = hiera('ssh_libcurl_openssl_dev_ensure', $ssh::default::libcurl_openssl_dev_ensure)
    $ssh_import_id_ensure       = hiera('ssh_import_id_ensure', $ssh::default::ssh_import_id_ensure)
    $configure_firewall         = hiera('ssh_configure_firewall', $ssh::default::configure_firewall)
    $port                       = hiera('ssh_port', $ssh::default::port)
    $allow_root_login           = hiera('ssh_allow_root_login', $ssh::default::allow_root_login)
    $allow_password_auth        = hiera('ssh_allow_password_auth', $ssh::default::allow_password_auth)
    $permit_empty_passwords     = hiera('ssh_permit_empty_passwords', $ssh::default::permit_empty_passwords)
    $users                      = hiera('ssh_users', $ssh::default::users)
    $user_groups                = hiera('ssh_user_groups', $ssh::default::user_groups)
  }
  else {
    $openssh_package_ensure     = $ssh::default::openssh_package_ensure
    $openssh_service_ensure     = $ssh::default::openssh_service_ensure
    $libcurl_openssl_dev_ensure = $ssh::default::libcurl_openssl_dev_ensure
    $ssh_import_id_ensure       = $ssh::default::ssh_import_id_ensure
    $configure_firewall         = $ssh::default::configure_firewall
    $port                       = $ssh::default::port
    $allow_root_login           = $ssh::default::allow_root_login
    $allow_password_auth        = $ssh::default::allow_password_auth
    $permit_empty_passwords     = $ssh::default::permit_empty_passwords
    $users                      = $ssh::default::users
    $user_groups                = $ssh::default::user_groups
  }

  #-----------------------------------------------------------------------------
  # Operating system specific configurations

  case $::operatingsystem {
    debian, ubuntu: {
      $os_openssh_package             = 'openssh-server'
      $os_openssh_service             = 'ssh'
      $os_libcurl_openssl_dev_package = 'libcurl4-openssl-dev'
      $os_ssh_import_id_package       = 'ssh-import-id'

      $os_sshd_config_file            = '/etc/ssh/sshd_config'
      $os_sshd_config_template        = 'ssh/sshd_config.erb'

      $os_init_bin                    = '/etc/init.d/ssh'
    }
    default: {
      fail("The ssh module is not currently supported on ${::operatingsystem}")
    }
  }
}
