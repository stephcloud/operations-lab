# VM Baseline Runbook — Lab 01: VM Genesis

Server: `bedrock-vm-01`, AWS EC2 t3.micro, Ubuntu 26.04 LTS.

## Updating the system

```bash
sudo apt update && sudo apt upgrade -y
```

Pulled in a kernel update on first run, which needs a reboot to fully apply (not urgent, noted for later).

## Installing the tools

```bash
sudo apt install -y unattended-upgrades fail2ban ufw htop iotop ncdu jq shellcheck
```

fail2ban and ufw are the two that matter most for security. The rest (htop, iotop, ncdu, jq, shellcheck) are day-to-day diagnostic tools I'll lean on in later labs.

## Turning on automatic security updates

```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

Select Yes at the prompt. Confirm it stuck:

```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
```

Both lines should read `"1"`.

## Setting a real hostname

```bash
sudo hostnamectl set-hostname bedrock-vm-01
```

AWS gives you an auto-generated `ip-172-...` name by default — not something you want to see in logs six months from now.

## Firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw enable
```

Order matters here — allow SSH before enabling, or you lock yourself out.

## Timezone

```bash
sudo timedatectl set-timezone Africa/Lagos
```

## SSH hardening

Edited `/etc/ssh/sshd_config` directly with nano instead of sed, mainly to actually see what was in the file rather than blindly running a find-and-replace.

Changed:
- `#PermitRootLogin prohibit-password` → `PermitRootLogin no`
- `#PasswordAuthentication yes` → `PasswordAuthentication no`

Checked the config wouldn't break anything before restarting:

```bash
sudo sshd -t
```

Silent output = valid config. Then:

```bash
sudo systemctl restart ssh
```

Kept the original terminal session open through this step, just in case — if the restart had broken something, I'd still have had a way in.

## Confirming everything worked

```bash
hostnamectl
sudo ufw status verbose
sudo systemctl status fail2ban --no-pager
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config
```

## The networking issue that actually ate most of the time

This VPC's default setup had no Internet Gateway attached — meaning the security group could technically allow SSH traffic in, but there was no route for it to actually reach the instance. Every connection attempt just timed out silently, no useful error message.

Fixed by:
1. Creating and attaching an Internet Gateway to the VPC
2. Adding a `0.0.0.0/0 → igw-xxxxx` route to the subnet's route table
3. Confirming that route table was actually associated with the right subnet

Lesson: check VPC → Subnet → IGW → Route Table *before* launching anything, not after chasing a timeout for twenty minutes.

## What the SSH changes actually do

- `PasswordAuthentication no` — password login is gone. Key-based auth only from here on.
- `PermitRootLogin no` — root can't log in directly over SSH at all, even with a key. Admin access only happens through a regular user plus `sudo`.
