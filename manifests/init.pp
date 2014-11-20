class collectd {
  $collectd_profile = hiera('collectd_profile')
  $collectd_server_package = hiera('collectd_server_package')
  $collectd_agent_package = hiera('collectd_agent_package')
  $collectd_service = hiera('collectd_service')
  $collectd_ensure = hiera('collectd_ensure')
  $collectd_config = hiera('collectd_config')
  #$collectd_server = hiera('collectd_server')
  #$collectd_port = hiera('collectd_port')
  $collectd_data_dir = hiera('collectd_data_dir')
  $collectd_data_dir_parents = hiera('collectd_data_dir_parents')
  $collectd_include_dir = hiera('collectd_include_dir')
  $collectd_base_dir= hiera('collectd_base_dir')
  $collectd_plugin_dir= hiera('collectd_plugin_dir')
  $collectd_pid_file= hiera('collectd_pid_file')
  $collectd_types_db= hiera('collectd_types_db')
  $collectd_plugins = hiera_hash('collectd_plugins')

  $root_group = hiera('root_group')

  case $collectd_ensure {
    true : {
                $collectd_package_ensure = 'present'
                $collectd_config_ensure = 'file'
    }
    default : {
                $collectd_package_ensure = 'absent'
                $collectd_config_ensure = 'absent'
    }
  }

  if ( $collectd_server_package != $collectd_agent_package ) {
    case $collectd_profile {
      'agent': {
                 $collectd_package = $collectd_agent_package
                 package { $collectd_server_package:
                   ensure => absent,
                   before => Package[$collectd_package],
                 }
      }              
      'server': {
                  $collectd_package = $collectd_server_package
                  package { $collectd_agent_package:
                    ensure => absent,
                    before => Package[$collectd_package],
                  }
      }
    }
  } else {
    $collectd_package = $collectd_agent_package
  }

  package { $collectd_package:
    ensure => $collectd_package_ensure,
  }

  file { $collectd_include_dir:
    ensure  => directory,
    owner   => 'root',
    group   => $root_group,
    mode    => '0750',
    require => Package[$collectd_package],
  }

  if ( $collectd_profile == 'server' ) {
    file { [ $collectd_data_dir_parents, $collectd_data_dir ]:
      ensure  => directory,
      owner   => 'root',
      group   => $root_group,
      mode    => '0750',
      require => Package[$collectd_package],
    }
  }

  file { $collectd_config:
    ensure  => $collectd_config_ensure,
    content => template("collectd/collectd.conf.erb"),
    owner   => 'root',
    group   => $root_group,
    mode    => '0640',
    require => File[$collectd_include_dir],
  }

  $collectd_plugins_defaults = {
    'require' => File[$collectd_config],
    'notify'  => Service[$collectd_service],
  }

  if $collectd_plugins {
    create_resources('collectd::plugin', $collectd_plugins, $collectd_plugins_defaults)
  }

  service { $collectd_service:
    ensure     => $collectd_ensure,
    enable     => $collectd_ensure,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File[$collectd_config],
  }

}
