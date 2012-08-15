
class ssh::default {

  $package_ensure             = 'present'
  $service_ensure             = 'running'
  $dev_ensure                 = 'present'
  $extra_ensure               = 'present'

  $configure_firewall         = 'true'
  $port                       = 22

  $allow_root_login           = 'false'
  $allow_password_auth        = 'false'
  $permit_empty_passwords     = 'false'

  $users                      = []
  $user_groups                = [ 'admin' ]

  #---

  case $::operatingsystem {
    debian, ubuntu: {
      $package                     = 'openssh-server'
      $service                     = 'ssh'

      $dev_packages                = [ 'libcurl4-openssl-dev' ]
      $extra_packages              = [ 'ssh-import-id' ]

      $sshd_config_file            = '/etc/ssh/sshd_config'
      $sshd_config_template        = 'ssh/sshd_config.erb'

      $init_bin                    = '/etc/init.d/ssh'
    }
    default: {
      fail("The ssh module is not currently supported on ${::operatingsystem}")
    }
  }
}
