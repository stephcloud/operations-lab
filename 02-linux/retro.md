# Module 02 Retro

## What went well
- Server hardening (UFW, fail2ban, SSH key-only auth) all worked cleanly once the actual networking was sorted out.
- The multi-user permission model (groups, ACLs, restricted sudo, setgid) was the most genuinely useful lab in this module - real day-one-at-a-job material, not just syntax practice.
- Writing the four diagnostic scripts by hand, then validating with shellcheck and a smoke test, made the "write it once, use it forever" argument for scripting land in a way that just reading about it wouldn't have.
- The Lynis audit gave a concrete, measurable improvement (62 to 73) from five focused fixes rather than trying to chase every one of the 44 suggestions.

## What was harder than expected
- VirtualBox on this machine hit two separate blockers (a broken unattended-install ISO reference, then a graphics driver crash) before switching to a real EC2 instance instead. Lost real time here for something unrelated to the actual lab content.
- The EC2 instance's default VPC had no Internet Gateway attached, which produced a silent SSH timeout with no useful error message. Took a while to trace back to the actual cause rather than assume it was a security group or key issue.
- Alice and Bob ended up in the unrestricted `sudo` group in addition to the intentionally restricted sudoers rule, which meant the restriction wasn't actually doing anything until caught during the final audit step. Easy to miss if you don't specifically check `sudo -lU` after setting up a restricted rule.

## What I'd do differently next time
- Verify VPC -> Subnet -> Internet Gateway -> Route Table before launching an instance, not after chasing a connection timeout.
- When restricting sudo access for a group, immediately verify with `sudo -lU <user>` rather than assuming the sudoers file alone is sufficient - group membership elsewhere can silently override it.
- Consider Multipass or a cloud VM as the default path for future VM-based labs, rather than VirtualBox, given the driver issues hit here.

## Date
2026-07-11
