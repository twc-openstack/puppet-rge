# Reboot Guard Enforcer

## Overview

This module helps you to prevent reboots except when you want them to occur.

## Module Description

RGE is intended to ensure that reboots triggered by a puppet run only
occur when you expect them to.  It does this establishing a special
reboot stage that occurs before `main`, but that will only be enabled if
the reboot guard is disarmed.  Any resources that require a reboot after
being applied (kernel upgrades, network changes),  can be placed in this
run stage.

## How it works

In a normal puppet run, the guard is armed, and nothing special happens.
To disarm the reboot guard, the file `/etc/RGE_DISARMED` must be
created.  If this file exists when puppet starts, then the following
series of events should occur:

1. All classes that were passed in as a parameter are declared in the
RGE stage and required to be applied before the reboot

2. The file that disarms the guard (`/etc/RGE_DISARMED`) will be
removed.

3. The reboot resource will be applied.  This uses reboot module.  The
puppetlabs reboot module will spawn a background process that waits for
the current agent to exit.  It will then cleanly abort the current run
and submit a report before exiting.  The machine will then be rebooted
with the `shutdown` command.

### Note

The [puppetlabs reboot
module](https://forge.puppetlabs.com/puppetlabs/reboot) only supports
Windows.  If you're using Linux, you probably want to use my fork of the
puppet labs module found at
<https://github.com/dvorak/puppetlabs-reboot>.

## Usage

The only parameter that the main `rge` class accepts is one for the
classes to put in the RGE stage.  If you prefer to manually place your
classes in the RGE stage, then the RGE stage name is `rge_reboot`.

    class rge {
      classes => 'my::rge::kernel_upgrade',
    }

Alternatively, multiple classes can be specified by providing an array of
class names:

    class rge {
      classes => [
        'my::rge::kernel_upgrade',
        'my::rge::driver_install',
      ]
    }

If no classes are specified, then a
`hiera_array('rge::classes_include')` call will be used to lookup the
classes to include.  This can be useful to include roles from multiple
categories (role, site, etc).

# Implementation

There is a rge::reboot class that is not intended to be used directly.
Stages cannot be set on resources directly, but only on classes.  In
order to put the `reboot` and `file` resource for removing the the
`/etc/RGE_DISARMED` file in the RGE stage, they have to be in a
different class.
