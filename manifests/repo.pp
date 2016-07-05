class filebeat::repo {
  case $::osfamily {
    'Debian': {
      include ::apt
      Class['apt::update'] -> Package['filebeat']

      if !defined(Apt::Source['beats']){
        apt::source { 'beats':
          location    => 'http://packages.elastic.co/beats/apt',
          release     => 'stable',
          repos       => 'main',
          key         => 'D88E42B4',
          key_source  => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
          include_src => false,
        }
      }
    }
    'RedHat', 'Linux': {
      if !defined(Yumrepo['beats']){
        yumrepo { 'beats':
          descr    => 'elastic beats repo',
          baseurl  => 'https://packages.elastic.co/beats/yum/el/$basearch',
          gpgcheck => 1,
          gpgkey   => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
          enabled  => 1,
        }
      }
    }
    'Suse': {
      exec { 'topbeat_suse_import_gpg':
        command => 'rpmkeys --import http://packages.elastic.co/GPG-KEY-elasticsearch',
        unless  => 'test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['beats'] ],
      }
      if !defined(Zypprepo['beats']){
        zypprepo { 'beats':
          baseurl     => 'https://packages.elastic.co/beats/yum/el/$basearch',
          enabled     => 1,
          autorefresh => 1,
          name        => 'beats',
          gpgcheck    => 1,
          gpgkey      => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
          type        => 'yum',
        }
      }
    }
    default: {
      fail($filebeat::kernel_fail_message)
    }
  }
}
