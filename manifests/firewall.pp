
class ssh::firewall ( $port = 22 ) {

  firewall { "150 - INPUT allow new SSH connections":
    action => accept,
    chain => 'INPUT',
    state => 'NEW',
    proto => 'tcp',
    dport => $port,
  }
}
