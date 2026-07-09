# Multi-User Server Runbook — Lab 02

Setting up 4 accounts on `bedrock-vm-01` with different access levels: two full developers, one read-only, one isolated contractor.

## Groups

```bash
sudo groupadd dev
sudo groupadd readonly
sudo groupadd contractor
sudo groupmod -n devs dev
```

Created singular names first, renamed `dev` to `devs` afterward to match the intended convention. Since the group was still empty at that point, `groupmod -n` was a clean rename with no side effects.

## Users

```bash
sudo adduser alice --gecos "Alice Adams,,,"
sudo adduser bob --gecos "Bob Brown,,,"
sudo adduser chen --gecos "Chen Chao,,," --disabled-password
sudo adduser dee --gecos "Dee Dean,,," --disabled-password
```

`--disabled-password` on chen and dee blocks password login from account creation — both are meant to be key-only or otherwise controlled, not casual logins.

This Ubuntu version's `adduser` doesn't support `--expiredate` directly, so Dee's expiry was set separately:

```bash
sudo chage -E $(date -d "+30 days" +%Y-%m-%d) dee
```

## Group assignments

```bash
sudo usermod -aG devs alice
sudo usermod -aG devs bob
sudo usermod -aG readonly chen
sudo usermod -aG contractor dee
```

Note: initially added alice and bob to the plain `sudo` group as well, which gave them unrestricted admin access and defeated the point of the restricted sudoers rule below. Removed them from `sudo` afterward:

```bash
sudo gpasswd -d alice sudo
sudo gpasswd -d bob sudo
```

Their only path to admin commands now is the `devs`-scoped sudoers rule, not blanket sudo group membership.

## Shared codebase folder

```bash
sudo mkdir -p /srv/codebase
sudo chgrp devs /srv/codebase
sudo chmod 2775 /srv/codebase
```

`chgrp` only — the folder stays owned by root since it's shared, not personal. The `2` in `2775` sets the setgid bit, so anything created inside inherits the `devs` group automatically instead of the creator's personal group.

## Read-only access for Chen

A regular folder can only belong to one group. Chen's `readonly` group needed access to the same folder already owned by `devs`, so ACLs were used to layer an extra rule on top:

```bash
sudo apt install -y acl
sudo setfacl -R -m g:readonly:rx /srv/codebase
sudo setfacl -dR -m g:readonly:rx /srv/codebase
```

The `-d` version sets it as a default ACL, so new files created later automatically get the same rule, not just what already exists.

## Dee's isolated folder

```bash
sudo mkdir -p /srv/contractors/dee
sudo chown dee:contractor /srv/contractors/dee
sudo chmod 750 /srv/contractors/dee
```

Unlike the shared codebase folder, this one is genuinely owned by Dee personally (`chown`, not just `chgrp`), since it's meant to be hers alone. `750` gives her full control, lets the `contractor` group view it, and blocks everyone else entirely. If a second contractor joined later, they'd get their own separate folder the same way — group membership doesn't imply folder access here, ownership does.

## Restricted sudo for devs

```bash
sudo tee /etc/sudoers.d/devs <<'EOF2'
%devs ALL=(ALL) PASSWD: /usr/bin/apt, /usr/bin/systemctl, /usr/bin/journalctl
EOF2
sudo visudo -cf /etc/sudoers.d/devs
```

Alice and Bob can run sudo, but only for those three specific commands, not arbitrary root access. Validated the file's syntax with `visudo -cf` before trusting it.

## Final audit

```bash
getent passwd alice bob chen dee
groups alice bob chen dee
sudo -lU alice
sudo -lU chen
ls -la /srv/codebase
sudo getfacl /srv/codebase
sudo chage -l dee
```

Confirmed: alice and bob restricted to the three allowed commands, chen has no sudo at all, the ACL grants chen's group read-only access to the shared folder, and dee's account is set to expire 30 days from creation.
