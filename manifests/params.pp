
class ssh::params {

  #-----------------------------------------------------------------------------

  $sshd_config     = '/etc/ssh/sshd_config'
  $ssh_init_script = '/etc/init.d/ssh'

  case $::operatingsystem {
    debian: {}
    ubuntu: {
      $open_ssh_server_version      = '1:5.9p1-5ubuntu1'
      $libcurl4_openssl_dev_version = '7.22.0-3ubuntu4'
      $ssh_import_id_version        = '2.10-0ubuntu1'
    }
    centos: {}
    redhat: {}
  }
}
