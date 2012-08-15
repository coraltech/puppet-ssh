
class ssh::params inherits ssh::default {

  $package                = module_param('package')
  $package_ensure         = module_param('package_ensure')

  $service                = module_param('service')
  $service_ensure         = module_param('service_ensure')

  $dev_packages           = module_array('dev_packages')
  $dev_ensure             = module_param('dev_ensure')

  $extra_packages         = module_array('extra_packages')
  $extra_ensure           = module_param('extra_ensure')

  #---

  $init_bin               = module_param('init_bin')
  $config_file            = module_param('config_file')
  $config_template        = module_param('config_template')

  $configure_firewall     = module_param('configure_firewall')
  $port                   = module_param('port')

  $allow_root_login       = module_param('allow_root_login')
  $allow_password_auth    = module_param('allow_password_auth')
  $permit_empty_passwords = module_param('permit_empty_passwords')

  $users                  = module_array('users')
  $user_groups            = module_array('user_groups')
}
