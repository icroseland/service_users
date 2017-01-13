# actually do the heavy lifting of generating a service user
define service_users::user_resource(
  $uid,
  $gid,
  $group,
  $home,
  $shell,
  $password,
  $comment,
  $ensure,
  $system,
  $ssh_authorized_keys_array,
  $ssh_public_key,
  $sudoers_array,
){

#set user defaults.. 
user {
  ensure     => $ensure,
  uid        => $uid,
  gid        => $gid,
  comment    => $comment,
  shell      => $shell,
  managehome => true,
  password   => $password,
  home       => $home,
}


# lookup the specific user we are installing
$current_user = hiera_hash("service_users::user_masterlist::${name}")

if $name == 'root' {
  fail('Please do not try whatever you are trying for the root user.')
}
group { $name:
      ensure => $ensure,
      gid    => $gid,
      system => $system,
}
user { $name:
  ensure     => $current_user[ensure],
  uid        => $current_user[uid],
  gid        => $current_user[gid],
  comment    => $current_user[comment],
  shell      => $current_user[shell],
  managehome => $current_user[managehome],
  password   => $current_user[password],
  home       => $current_user[home],
  require    => Group[[$group, $name]]
}

if $ssh_authorized_keys_array != undef {
  file { "${home}/.ssh":
    ensure  => directory,
    owner   => $name,
    group   => $gid,
    mode    => '0700',
    require => User[$name]
  }
  file { "${home}/.ssh/authorized_keys":
    ensure  => file,
    owner   => $name,
    group   => $gid,
    mode    => '0700',
    content => $current_user[ssh_authorized_keys_array],
  }
}
if $ssh_public_key != undef {
  file { "${home}/.ssh/public_key":
    ensure  => file,
    owner   => $name,
    group   => $gid,
    mode    => '0700',
    content => $current_user[ssh_public_key]
    }
}

## rewrite the sudo stuff.. drag in a hash from the hash with an array of the actual rules, and
## key value pars for the settigns..
##
## sudo
  if $allow_sudo {
    if $allow_sudo_nopasswd {
      $sudo_base_string = "${username} ALL=(ALL) NOPASSWD: ALL\n"
    } else {
      $sudo_base_string = "${username} ALL=(ALL) ALL\n"
    }

    if $sudo_requiretty {
      $sudo_tty_boolean = ''
    } else {
      $sudo_tty_boolean = '!'
    }
    $sudo_tty_string = "Defaults:${username} ${sudo_tty_boolean}requiretty\n"

    $sudo_conf_string = "${sudo_base_string}${sudo_tty_string}"
    sudo::conf { $username:
        content  => $sudo_conf_string,
        priority => 'zz'
    }
  }



}
