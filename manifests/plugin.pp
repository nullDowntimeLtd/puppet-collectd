define collectd::plugin {

  $collectd_include_dir = hiera('collectd_include_dir')
  $collectd_server = hiera('collectd_server')
  $collectd_port = hiera('collectd_port')
  $collectd_profile = hiera('collectd_profile')
  $collectd_data_dir = hiera('collectd_data_dir')
  $collectd_carbon_host = hiera('collectd_carbon_host')
  $collectd_carbon_port = hiera('collectd_carbon_port')

  file { "collectd/collectd_plugin-${title}.conf":
    content => template("collectd/collectd_plugin-${title}.conf.erb"),
    path    => "${collectd_include_dir}/${title}.conf",
  }
}
