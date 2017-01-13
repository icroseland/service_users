# add the big secondary groups that users may belong to .. 
define  service_users::groups(
$ensure = present,
$gid = undef,
$system = undef,
){

$group_entry = hiera_hash("service_users::group_hash::${name}")
$provider    = hiera_hash('service_users::group_provider', undef)

  group {
    ensure   => $ensure,
    gid      => $gid,
    provider => $provider
    system   => $system
  }

  group { $name:
    ensure => $group_entry[ensure],
    gid    => $group_entry[gid],
    system => $system
  }
}
