
class ssh::firewall ( $port = $ssh::params::port ) inherits ssh::params {

  firewall { "150 INPUT Allow new SSH connections":
    action => accept,
    chain => 'INPUT',
    state => 'NEW',
    proto => 'tcp',
    dport => $port,
  }
}
