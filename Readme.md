# Ansible with Docker

This is a testbed for Ansible playbook development with dockerized nodes.

## Usage

You need to have Ansible, Docker and [Just](https://github.com/casey/just) installed. Then run the following command:

```bash
just setup
```

You should then have two containers running:

```bash
❯ docker ps -a
CONTAINER ID   IMAGE        COMMAND               CREATED             STATUS             PORTS     NAMES
ddbb99df75f9   fedora_ssh   "/usr/sbin/sshd -D"   About an hour ago   Up About an hour             fedora-2
cc2cfe95a724   fedora_ssh   "/usr/sbin/sshd -D"   About an hour ago   Up About an hour             fedora-1
```

## Login comfort

Run the `just update-ssh-config` command to create a new local SSH configuration. After that you should be able to login for example with `just ssh fedora-1`.

## Testing

`just test` the setup or run `ansible-playbook os-update.yaml`.

