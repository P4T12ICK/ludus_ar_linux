# Testing Multiple Variable Combinations in Molecule

This document explains different approaches to test multiple role variable combinations using Molecule.

## Method 1: Multiple Scenarios (Recommended)

Create separate scenario directories, each with different variable combinations.

### Structure
```
molecule/
├── default/
│   ├── molecule.yml
│   ├── converge.yml      # Variables for default scenario
│   └── verify.yml
├── splunk-9.3/
│   ├── molecule.yml
│   ├── converge.yml      # Variables for Splunk 9.3
│   └── verify.yml
└── custom-config/
    ├── molecule.yml
    ├── converge.yml      # Variables for custom configuration
    └── verify.yml
```

### Example: `molecule/default/converge.yml`
```yaml
---
- name: Converge
  hosts: all
  roles:
    - role: ../../..
      vars:
        ludus_ar_linux_splunk_uf_url: https://download.splunk.com/products/universalforwarder/releases/9.4.7/linux/splunkforwarder-9.4.7-2a9293b80994-linux-amd64.deb
        ludus_ar_linux_splunk_password: changeme123!
        ludus_ar_linux_splunk_ip: "10.2.20.1"
```

### Example: `molecule/splunk-9.3/converge.yml`
```yaml
---
- name: Converge
  hosts: all
  roles:
    - role: ../../..
      vars:
        ludus_ar_linux_splunk_uf_url: https://download.splunk.com/products/universalforwarder/releases/9.3.0/linux/splunkforwarder-9.3.0-51ccf43db5bd-linux-2.6-amd64.deb
        ludus_ar_linux_splunk_password: changeme123!
        ludus_ar_linux_splunk_ip: "10.2.20.1"
```

### Running Multiple Scenarios

**Test all scenarios:**
```bash
molecule test --all
```

**Test specific scenario:**
```bash
molecule test -s default
molecule test -s splunk-9.3
```

**Test multiple scenarios:**
```bash
for scenario in default splunk-9.3; do
  molecule test -s $scenario
done
```

### CI/CD Integration (GitHub Actions)

Update your workflow matrix to include all scenarios:

```yaml
strategy:
  matrix:
    scenario:
      - default
      - splunk-9.3
      - custom-config
```

## Method 2: Multiple Platforms in One Scenario

You can define multiple platforms with different variables in a single scenario.

### Example: `molecule/default/molecule.yml`
```yaml
---
driver:
  name: docker
platforms:
  - name: instance-splunk-94
    image: geerlingguy/docker-ubuntu2204-ansible:latest
    platform: linux/amd64
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns_mode: host
    command: "/lib/systemd/systemd"
    pre_build_image: true
  - name: instance-splunk-93
    image: geerlingguy/docker-ubuntu2204-ansible:latest
    platform: linux/amd64
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns_mode: host
    command: "/lib/systemd/systemd"
    pre_build_image: true
```

### Example: `molecule/default/converge.yml`
```yaml
---
- name: Converge
  hosts: all
  roles:
    - role: ../../..
      vars:
        ludus_ar_linux_splunk_uf_url: "{{ 'https://download.splunk.com/products/universalforwarder/releases/9.4.7/linux/splunkforwarder-9.4.7-2a9293b80994-linux-amd64.deb' if 'splunk-94' in inventory_hostname else 'https://download.splunk.com/products/universalforwarder/releases/9.3.0/linux/splunkforwarder-9.3.0-51ccf43db5bd-linux-2.6-amd64.deb' }}"
        ludus_ar_linux_splunk_password: changeme123!
        ludus_ar_linux_splunk_ip: "10.2.20.1"
```

**Note:** This approach is less flexible and harder to maintain than multiple scenarios.

## Method 3: Using Inventory Variables

You can also define variables in the inventory file.

### Example: `molecule/default/molecule.yml`
```yaml
---
provisioner:
  name: ansible
  inventory:
    host_vars:
      instance:
        ludus_ar_linux_splunk_uf_url: https://download.splunk.com/products/universalforwarder/releases/9.4.7/linux/splunkforwarder-9.4.7-2a9293b80994-linux-amd64.deb
        ludus_ar_linux_splunk_password: changeme123!
        ludus_ar_linux_splunk_ip: "10.2.20.1"
```

## Method 4: Using Environment Variables

You can pass variables via environment variables and use them in converge.yml.

### Example: `molecule/default/converge.yml`
```yaml
---
- name: Converge
  hosts: all
  roles:
    - role: ../../..
      vars:
        ludus_ar_linux_splunk_uf_url: "{{ lookup('env', 'SPLUNK_UF_URL') | default('https://download.splunk.com/products/universalforwarder/releases/9.4.7/linux/splunkforwarder-9.4.7-2a9293b80994-linux-amd64.deb') }}"
        ludus_ar_linux_splunk_password: "{{ lookup('env', 'SPLUNK_PASSWORD') | default('changeme123!') }}"
        ludus_ar_linux_splunk_ip: "{{ lookup('env', 'SPLUNK_IP') | default('10.2.20.1') }}"
```

Then run:
```bash
SPLUNK_UF_URL=https://... SPLUNK_PASSWORD=secret molecule test -s default
```

## Best Practices

1. **Use Method 1 (Multiple Scenarios)** for most cases - it's the most maintainable
2. Keep `molecule.yml` and `verify.yml` identical across scenarios when possible
3. Only vary `converge.yml` for different variable combinations
4. Use descriptive scenario names (e.g., `splunk-9.3`, `custom-password`, `production-config`)
5. Document what each scenario tests in a README or comments

## Example: Creating a New Scenario

```bash
# 1. Create scenario directory
mkdir -p molecule/my-scenario

# 2. Copy base files
cp molecule/default/molecule.yml molecule/my-scenario/
cp molecule/default/verify.yml molecule/my-scenario/

# 3. Create converge.yml with your variables
cat > molecule/my-scenario/converge.yml <<EOF
---
- name: Converge
  hosts: all
  roles:
    - role: ../../..
      vars:
        ludus_ar_linux_splunk_uf_url: YOUR_URL_HERE
        ludus_ar_linux_splunk_password: YOUR_PASSWORD_HERE
        ludus_ar_linux_splunk_ip: YOUR_IP_HERE
EOF

# 4. Test it
molecule test -s my-scenario
```
