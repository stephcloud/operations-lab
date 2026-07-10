# SSH at Scale Runbook — Lab 04

Set up a named SSH shortcut, an SSH agent, and extra server-side hardening on top of what was already configured in Lab 01.

## Named host in ~/.ssh/config

Lives on the local machine (WSL2), not the server:

```bash
cat > ~/.ssh/config <<'EOF2'
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  IdentitiesOnly yes
  HashKnownHosts yes

Host bedrock-dev
  HostName 100.25.42.181
  User ubuntu
  IdentityFile ~/.ssh/project-key.pem
  Port 22
EOF2
chmod 600 ~/.ssh/config
```

`IdentitiesOnly yes` matters more than it looks - without it, SSH tries every key in the agent against every host, which can trip account lockouts on servers with login attempt limits. `Host *` applies to every connection; the named `bedrock-dev` block only fires for that shortcut specifically.

Once set up, connecting is just:

```bash
ssh bedrock-dev
```

instead of the full `-i` and IP every time. The public IP changes every time the instance stops and restarts (no Elastic IP attached), so this file needs the HostName line updated after a restart.

## SSH agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/project-key.pem
ssh-add -l
```

Loads the key into memory for the session so it doesn't need to be re-read from disk on every connection. More useful once a key has a passphrase, but good habit either way.

## Additional server-side hardening

Lab 01 already set `PermitRootLogin no` and `PasswordAuthentication no`. This adds more layers, in a separate drop-in file rather than editing the main config directly:

```bash
sudo tee -a /etc/ssh/sshd_config.d/99-bedrock.conf <<'EOF2'
MaxAuthTries 3
LoginGraceTime 30s
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers ubuntu alice bob
EOF2
sudo sshd -t
sudo systemctl reload ssh
```

- `MaxAuthTries 3` - drops the connection after 3 failed attempts
- `LoginGraceTime 30s` - disconnects anyone who doesn't finish authenticating within 30 seconds
- `ClientAliveInterval 300` / `ClientAliveCountMax 2` - drops genuinely dead sessions after roughly 10 minutes
- `AllowUsers ubuntu alice bob` - explicit allowlist; chen and dee exist on the system but can't SSH in at all, matching their read-only/isolated roles from Lab 02

Validated with `sshd -t` before reloading, same safety check as Lab 01.

## What's missing on purpose

The lab's full version of this exercise assumes 3+ servers and covers jump host (bastion) config - connecting to an internal server through a public-facing one via `ProxyJump`. Only one server is running right now, so that part wasn't tested for real. The config pattern for later:
Host bedrock-app-*
User ubuntu
IdentityFile ~/.ssh/id_ed25519_lumberyard_prod
ProxyJump bedrock-prod

Worth revisiting once there's an actual second server to jump through.

## Verification

```bash
ssh bedrock-dev "hostname && uptime"
sudo sshd -T | grep -E "maxauthtries|logingracetime|allowusers|clientaliveinterval"
```
