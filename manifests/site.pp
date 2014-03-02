$root = '/vagrant'

File {
  owner => 'root',
  group => 'root',
  mode  => '0644'
}

Exec {
  path => '/usr/sbin:/usr/bin:/sbin:/bin',
}

Package {
  require => Exec['apt-get update']
}

exec { 'apt-get update':
  command     => 'apt-get update'
}

class jre {
  package { 'default-jre':
    ensure => present
  }
}

class elasticsearch {
  include jre

  exec { 'dpkg -i elasticsearch':
    command => "dpkg -i ${::root}/elasticsearch-1.0.1.deb",
    creates => '/etc/elasticsearch',
    require => Class['jre']
  }

  vagrant_file { '/etc/elasticsearch/elasticsearch.yml':
    require => Exec['dpkg -i elasticsearch']
  }

  service { 'elasticsearch':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/elasticsearch/elasticsearch.yml'],
    require   => Exec['dpkg -i elasticsearch']
  }
}

class elasticsearch::head {
  file {
    '/var/www/elasticsearch-head':
      source  => "${::root}/elasticsearch-head",
      recurse => true,
      owner   => vagrant,
      group   => vagrant,
      mode    => '0644',
      require => Package['apache2'],
      ignore  => [
        '.git*',
        '.jshintrc',
        'package.json',
        '[Gg]runt*.js',
        'src',
        'test',
        'elasticsearch-head.sublime-project',
        'LICENSE*',
        'README*',
      ]
  }
}

class logstash {
  include jre

  exec { 'dpkg -i logstash':
    command => "dpkg -i ${::root}/logstash_1.3.3-1-debian_all.deb",
    creates => '/etc/logstash',
    require => Class['jre']
  }

  $files = [
    '/etc/logstash/conf.d/logstash.conf',
    '/etc/default/logstash',
  ]

  Vagrant_file {
    require => Exec['dpkg -i logstash']
  }

  vagrant_file {
    $files: ;
    '/etc/rsyslog.conf': ;
  }

  service { 'logstash':
    ensure    => running,
    enable    => true,
    subscribe => File[$files],
    require   => Exec['dpkg -i logstash']
  }

  service { 'rsyslog':
    subscribe => File['/etc/rsyslog.conf'],
    require   => Exec['dpkg -i logstash']
  }
}

class kibana {
  $kibana = 'kibana-3.0.0milestone5'

  package { 'apache2':
    ensure => present
  }

  exec { 'tar xf kibana':
    command => "tar -C /var/www -xf ${::root}/${kibana}.tar.gz",
    creates => "/var/www/${kibana}",
    require => Package['apache2']
  }

  file { '/var/www/kibana':
    ensure  => link,
    target  => $kibana,
    require => Package['apache2']
  }
}

include elasticsearch
include elasticsearch::head
include logstash
include kibana

define vagrant_file() {
  file { $name:
    ensure => present,
    source => "file://${::root}/files${name}"
  }
}
