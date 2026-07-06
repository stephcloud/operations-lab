# Module 01 Retro

## What went well
- Repo structure, ADRs, and signing all worked cleanly once I understood the difference between auth keys and signing keys.
- Reused an existing personal site (afunogu.online) instead of building a duplicate — saved time, and cross-linking it back to operations-lab satisfied Lab 03 without extra work.
- Testing the dotfiles install.sh in a throwaway /tmp/fake-home folder before trusting it caught nothing broken, but proved the reproducibility claim instead of just assuming it.

## What was harder than expected
- GitHub Pages got stuck in an "errored" deployment state on the stephcloud.github.io repo, unrelated to anything I did wrong. Cost real time chasing a red herring before realizing operations-lab's own GitHub Pages (via README rendering) already satisfied the lab's actual requirement.
- Registering an SSH signing key with GitHub needed an extra permission scope (`admin:ssh_signing_key`) that wasn't obvious upfront — hit a 404 before finding the fix.
- Almost hardcoded my home directory path into a tracked dotfiles config before catching it and switching to `~`-relative paths.

## What I'd do differently next time
- Check GitHub Pages status early when something looks stuck, rather than assuming it's my code.
- Default to `~`-relative paths in any config from the start, instead of fixing it after the fact.

## Date
2026-07-06
