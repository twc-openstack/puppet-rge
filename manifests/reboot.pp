class rge::reboot {
  notify { 'rge':
    message  => 'reboot guard is DISARMED, reboot allowed!',
    before   => File['/etc/RGE_DISARMED'],
  }

  file { '/etc/RGE_DISARMED':
    ensure => 'absent',
    notify => Reboot[guard],
  }

  reboot { 'guard': }
}
