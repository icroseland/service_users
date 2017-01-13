# create all of users
#
class service_users (
$user_hash = hiera_hash('service_users::user_hash', undef),
$groups_hash = hiera('service_users::groups', undef)
){
  $hashDefaults = {
    group                     => undef,
    password                  => '!!',
    comment                   => undef,
    ensure                    => 'present',
    system                    => false,
    ssh_authorized_keys_array => undef,
    sudoers_array             => undef,
  }
  $enable_sudo         = hiera('sudo::enable', false),
  $purge               = hiera('sudo::purge', false),
  $config_file_replace = hiera('sudo::config_file_replace', false)
  $ldap_enable         = hiera('sudo::enable_ldap', false),
  $sudo_configs        = hiera_hash('sudo::configs', undef)
    if $enable_sudo = true {
      class { 'sudo':
        purge               => $purge,
        config_file_replace => $config_file_replace,
        ldap_enable         => $ldap_enable,
      }
    }->
  if $groups_hash != undef {
    create_resources(service_users::groups_resourse)
    }->
    create_resources(service_users::service_user_resource,\
    $user_hash, $hashDefaults)
  
}

