class rge (
  $classes = hiera_array('rge::classes_include', [])
) {
  stage { 'rge_reboot':
    before => Stage['main'],
  }

  if $::rge_reboot_allowed and $::rge_reboot_allowed != 'false' {
    class { $classes:
      stage  => 'rge_reboot',
      before => Class['rge::reboot'],
    }

    class { 'rge::reboot':
      stage => 'rge_reboot'
    }
  } else {
    notify { 'rge':
      message => 'reboot guard is ARMED, reboot not allowed!',
    }
  }
}
