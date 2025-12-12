# Molecule Testing

This directory contains Molecule configuration for testing the `ludus_ar_linux` Ansible role.

## What is Molecule?

Molecule is a testing framework for Ansible roles that helps you:
- Test your role against different platforms and scenarios
- Verify that your role works correctly
- Catch regressions before they reach production
- Document expected behavior through tests

## How Molecule Works

Molecule follows a workflow with several phases:

1. **Dependency**: Installs role dependencies (from `meta/main.yml` or `requirements.yml`)
2. **Create**: Creates test instances (Docker containers, VMs, etc.)
3. **Prepare**: Runs preparation playbooks (optional setup before converge)
4. **Converge**: Runs your role against the test instance
5. **Verify**: Runs verification tests to ensure everything worked
6. **Destroy**: Cleans up test instances

## Directory Structure

```
molecule/
├── default/              # Default test scenario
│   ├── molecule.yml      # Molecule configuration
│   ├── converge.yml      # Playbook that runs your role
│   └── verify.yml        # Verification tests
└── requirements.txt      # Python dependencies for Molecule
```

## Installation

Install Molecule and its dependencies:

```bash
pip install -r molecule/requirements.txt
```

Or install manually:

```bash
pip install 'molecule>=5.0.0' 'molecule-plugins[docker]>=2.0.0' 'ansible-core>=2.12.0'
```

**Note:** In Molecule 4+, the Docker driver is a separate plugin (`molecule-plugins[docker]`), so make sure to install it separately.

**Prerequisites:**
- Docker (for the Docker driver)
- Python 3.8+
- Ansible

**Required Ansible Collections:**
The Docker driver requires these collections (automatically installed via `molecule/collections.yml`):
- `community.docker>=3.10.2`
- `ansible.posix>=1.4.0`

## Usage

### Run all test phases

```bash
molecule test
```

This will:
1. Create containers
2. Run your role
3. Verify the results
4. Destroy containers

### Run individual phases

```bash
# Create test instances
molecule create

# Run your role (converge)
molecule converge

# Run verification tests
molecule verify

# Destroy test instances
molecule destroy
```

### Interactive debugging

```bash
# Create and converge, then login to the instance
molecule converge
molecule login
```

## Configuration Explained

### `molecule/default/molecule.yml`

- **driver**: Uses Docker to create test containers
- **platforms**: Defines the test instance (Ubuntu Jammy)
- **provisioner**: Configures how Ansible runs
- **verifier**: Uses Ansible for verification (can also use testinfra, goss, etc.)

### `molecule/default/converge.yml`

This playbook runs your role with test variables. It's equivalent to:

```yaml
- hosts: all
  roles:
    - ludus_ar_linux
  vars:
    ludus_ar_linux_splunk_uf_url: ...
    ludus_ar_linux_splunk_password: ...
    ludus_ar_linux_splunk_ip: ...
```

### `molecule/default/verify.yml`

This playbook contains assertions that verify:
- Splunk Universal Forwarder is installed
- osquery is installed and configured
- auditd is installed
- Sysmon Linux is installed
- ART (Adversary Emulation Library) is installed

## Customizing Tests

### Add more verification tests

Edit `molecule/default/verify.yml` to add more assertions:

```yaml
- name: Check if a service is running
  ansible.builtin.systemd:
    name: osqueryd
    state: started
  register: service_status

- name: Verify service is running
  ansible.builtin.assert:
    that:
      - service_status.status.ActiveState == 'active'
```

### Test different scenarios

Create additional scenarios:

```bash
molecule init scenario --scenario-name ubuntu-focal
```

This creates a new scenario directory where you can test against different platforms or configurations.

### Use different drivers

You can use other drivers like:
- `vagrant` - for VM-based testing
- `ec2` - for AWS EC2 instances
- `openstack` - for OpenStack clouds

Change the `driver.name` in `molecule.yml`.

## CI/CD Integration

Molecule tests are automatically run on every commit and pull request via GitHub Actions. The workflow file is located at `.github/workflows/molecule.yml`.

### GitHub Actions

The workflow:
- Runs on pushes to `main`/`master` branches
- Runs on pull requests targeting `main`/`master`
- Can be manually triggered via `workflow_dispatch`
- Uses Ubuntu runners with Docker support
- Installs Molecule and required collections
- Runs all Molecule test scenarios
- Uploads logs as artifacts if tests fail

### Viewing Test Results

1. Go to the **Actions** tab in your GitHub repository
2. Click on the workflow run you want to inspect
3. View the logs for each step
4. Download artifacts if tests failed (contains Molecule logs)

### Local Testing

You can still run tests locally:

```bash
molecule test
```

This is useful for:
- Quick iteration during development
- Debugging test failures
- Testing changes before pushing

## Troubleshooting

### Reboot task fails in Docker

The role includes a reboot task that will fail in Docker containers. This is expected behavior - Docker containers don't support rebooting. The verification tests check that all components are installed, which is what matters for testing.

### Container won't start

Make sure Docker is running and you have permissions:

```bash
docker ps  # Should work without errors
```

### Tests fail

1. Check the converge output: `molecule converge`
2. Login to the instance: `molecule login`
3. Manually verify what's installed
4. Update `verify.yml` if expectations are wrong

## Further Reading

- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Testing Guide](https://docs.ansible.com/ansible/latest/dev_guide/testing.html)
