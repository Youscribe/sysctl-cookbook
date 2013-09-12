Description
===========

Set sysctl values from Chef!

Attributes
==========

* `node['sysctl']` - A namespace for sysctl settings.

Usage
=====

There are two ways of setting sysctl values:

1. Set chef attributes in the **sysctl** namespace. e.g.:

        node.set['sysctl']['set swappiness'] = { 'vm.swappiness' => '20' }
2. Set values in a `cookbook_file` Resource.
3. With Resource/Provider.

Resource/Provider
=================

This Cookbook includes two LWRPs:

1. **sysctl**
2. **sysctl_multi**

sysctl
------

## Actions

- **:save** - Save and set a sysctl value (default).
- **:set** - Set a sysctl value.
- **:remove** - Remove a (previous set) sysctl.

## Attribute Parameters

- **variable** - Variable to manage. e.g. `net.ipv4.ip_forward`, `vm.swappiness`.
- **value** - Value to affect to variable. e.g. `1`, `0`.
- **priority** - The file prefix used for priority ordering, defaults to `40`.
- **path** - Path to a specific file.
- **source** - Source to the template file, defaults to `sysctl.conf.erb`.
- **cookbook** - Cookbook that contains the template file, default to `sysctl`.

### Examples

###ruby

    # Set 'vm.swappiness' to '60'. Will create /etc/sysctl.d/40-vm.wappiness.conf
    sysctl 'vm.swappiness' do
        value '60'
    end

####the same. will create `/etc/sysctl.d/40-vm_swappiness_to_60.conf`

    sysctl 'vm swappiness to 60' do
      variable 'vm.swappiness'
      value '60'
    end

####Remove /etc/sysctl.d/40-ip_config.conf
    sysctl 'ip config' do
      action :remove
    end

#### Set swappiness but don't save it.
    sysctl 'vm.swappiness' do
      action :set
      value '40'
    end


sysctl_multi
------------

### Actions

- **:save** - Save and set a sysctl value (default).
- **:set** - set a sysctl value.
- **:remove** - remove a (previous set) sysctl.

### Attribute Parameters

- **instructions** - Hash with instruction. e.g. `{variable => value, variable2 => value2}`.
  Override use of 'variable' and 'value'.
- **priority** - The file prefix used for priority ordering, defaults to `40`.
- **path** - Path to a specific file.
- **source** - Source to the template file, defaults to `sysctl.conf.erb`.
- **cookbook** - Cookbook that contains the template file, default to `sysctl`.

### Examples

####ruby
### set multi variables. will create /etc/sysctl.d/69-ip_config.conf
    sysctl_multi 'ip config' do
      priority '69'
      instructions {
        'net.ipv4.ip_forward' => '1',
        'net.ipv6.conf.all.forwarding' => '1',
        'net.ipv4.tcp_syncookies' => '1'}
    end

Notes
=====

As long as your cookbook depends on the sysctl cookbook, there is no need to
explicitly `include_recipe "sysctl::default"` before calling the **sysctl** or
**sysctl_multi** LWRPs.  They will include it if necessary.

The resource **execute[sysctl-p]** takes care of loading the settings into the
kernel.  If you have a resource that lays down `/etc/sysctl.conf` you will
probably want to `notifies :run, "execute[sysctl-p]"` from that resource.

Given the priority nature of the files, when *any* file is changed, the whole
set is reloaded.  This avoids the situation where `00-base.conf` disables ip
forwarding and `70-proxy.conf` re-enables it.  If something in `00-base.conf`
changed and *only* that file was reloaded, ip forwarding would be left disabled
which is not the expected behavior.

The resource **ruby_block[zap_sysctl_d]** walks through `/etc/sysctl.d/*.conf`
removing any files that would not be created by the **sysctl** or
**sysctl_multi** LWRPs.  When settings are no longer needed, you can just remove
them from your cookbook.  No need to change the resource to `action :remove` and
then remove the code at a later time.

This does poise a slight problem for files laid down in `/etc/sysctl.d` by other
means.  **ruby_block[zap_sysctl_d]** would remove them.  The work-around is to
create dummy resources with `action :nothing`.  For example,
`/etc/sysctl.d/88-raid-settings.conf` is delivered via a vendor's RPM.  Adding
the following _dummy_ resource will prevent the file from being removed.

####ruby
    sysctl 'raid-settings' do
      action :nothing
      priority '88'
      value ''
    end

