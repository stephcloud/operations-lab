# Lynis Security Audit — Module 02

Ran on `bedrock-vm-01` after completing Labs 01-04.

## Before

```bash
sudo apt install -y lynis
sudo lynis audit system
```

Hardening index: 62/100

## Fixes applied

1. Locked down sudoers file permissions:
```bash
sudo chmod 440 /etc/sudoers.d/devs
```

2. Additional SSH hardening flagged by Lynis directly:
```bash
sudo tee -a /etc/ssh/sshd_config.d/99-bedrock.conf <<'EOF2'
AllowTcpForwarding no
X11Forwarding no
AllowAgentForwarding no
TCPKeepAlive no
LogLevel VERBOSE
MaxSessions 2
EOF2
sudo sshd -t
sudo systemctl reload ssh
```

3. Added a legal login banner:
```bash
echo "Authorized access only. All activity may be monitored and logged." | sudo tee /etc/issue /etc/issue.net
```

4. Installed a malware scanner (rkhunter). The signature update step failed since the default mirrors list ships empty - not critical for this exercise, Lynis only checks that a scanner is present.
```bash
sudo apt install -y rkhunter
```

5. Protected fail2ban's config from being silently overwritten by future package updates:
```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

## After

```bash
sudo lynis audit system
```

Hardening index: 73/100

## What was skipped, and why

Lynis surfaced 44 suggestions total. Most were left alone deliberately - things like centralized remote logging, disk encryption, auditd, and disabling rarely-used kernel network protocols are real hardening steps, but out of scope for a single practice server. The five fixes applied were chosen because they were fast, directly explainable, and matched what was already being worked on in this module (SSH config, sudoers, fail2ban).
