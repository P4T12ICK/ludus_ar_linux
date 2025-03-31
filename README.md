# Ansible Role: ([Ludus](https://ludus.cloud)) Attack Range Linux

An Ansible Role that installs and configures Attack Range Linux Server.
This will install and configure Attack Range Linux Server similar to the Attack Range Linux Server in [Attack Range](https://github.com/splunk/attack_range)

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):
```
ludus_ar_linux_splunk_uf_url: https://download.splunk.com/products/universalforwarder/releases/9.3.0/linux/splunkforwarder-9.3.0-51ccf43db5bd-linux-2.6-amd64.deb
ludus_ar_linux_splunk_password: changeme123!
ludus_ar_linux_splunk_ip: "10.2.20.1"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: attack_range_linux
  roles:
    - P4T12ICK.ludus_ar_linux
```

## Example Ludus Range Config

```yaml
ludus:
  - vm_name: "{{ range_id }}-ar-splunk"
    hostname: "{{ range_id }}-ar-splunk"
    template: ubuntu-22.04-x64-server-template
    vlan: 20
    ip_last_octet: 1
    ram_gb: 16
    cpus: 8
    linux: true
    testing:
      snapshot: false
      block_internet: false
    roles:
      - P4T12ICK.ludus_ar_splunk
  - vm_name: "{{ range_id }}-ar-linux"
    hostname: "{{ range_id }}-ar-linux"
    template: ubuntu-22.04-x64-server-template
    vlan: 20
    ip_last_octet: 2
    ram_gb: 8
    cpus: 4
    linux: true
    roles:
      - P4T12ICK.ludus_ar_linux
    role_vars:
      ludus_ar_linux_splunk_ip: "10.2.20.1"
```

## License
Apache License 2.0

## Author Information
This role was created by [P4T12ICK](https://github.com/P4T12ICK), for [Ludus](https://ludus.cloud/).
