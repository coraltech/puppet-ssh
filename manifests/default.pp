
class ssh::default {
  $openssh_package_ensure     = 'present'
  $openssh_service_ensure     = 'running'
  $libcurl_openssl_dev_ensure = 'present'
  $ssh_import_id_ensure       = 'present'
  $configure_firewall         = 'true'
  $port                       = 22
  $allow_root_login           = 'false'
  $allow_password_auth        = 'false'
  $permit_empty_passwords     = 'false'
  $users                      = []
  $user_groups                = [ 'admin' ]
}
