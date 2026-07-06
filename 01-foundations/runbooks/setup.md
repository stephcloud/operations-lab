# Module 01 Runbook: Foundations Setup

## What this covers

This runbook documents everything set up in Module 01 (Foundations) and how to reproduce it on a fresh machine.

## 1. Portfolio repo

```bash
gh repo create operations-lab --public --description "Production-grade DevOps portfolio" --clone
cd operations-lab
mkdir -p ADRs 01-foundations/{labs,runbooks,screenshots,posts}
```

## 2. Architecture Decision Records

Two ADRs were written and committed to `ADRs/`:
- `ADR-0001-why-this-repo-exists.md` — reasoning for a single monolithic portfolio repo
- `ADR-0002-personal-engineering-principles.md` — 8 personal engineering principles

## 3. Personal site

GitHub Pages was enabled directly on `operations-lab` (Settings → Pages → Deploy from a branch → `main` → `/root`). GitHub's Jekyll processor auto-renders the README as a live page at:
`https://afunogu.online/operations-lab/`

This was cross-linked with an existing personal portfolio site (`afunogu.online`, hosted in a separate repo `stephcloud.github.io`), adding a project card there pointing back to `operations-lab`.

## 4. Signed commits (SSH-based)

```bash
# Generate a dedicated signing key (separate from auth key)
ssh-keygen -t ed25519 -C "stephcloud-signing-2026" -f ~/.ssh/id_ed25519_signing

# Configure Git to sign with it
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_signing.pub
git config --global commit.gpgsign true

# Allow local verification
echo "232054776+stephcloud@users.noreply.github.com $(cat ~/.ssh/id_ed25519_signing.pub)" >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers

# Register the key with GitHub as a signing key (requires extra scope)
gh auth refresh -h github.com -s admin:ssh_signing_key
gh ssh-key add ~/.ssh/id_ed25519_signing.pub --title "stephcloud-signing-2026" --type signing
```

**Validation:** `git log --show-signature -1` shows "Good signature." GitHub shows a green "Verified" badge on the commit.

## 5. Dotfiles repo

A second, separate repo (`dotfiles`) tracks reproducible shell/Git configs:

```bash
gh repo create dotfiles --public --clone
mkdir -p bash git
cp ~/.bashrc bash/.bashrc
cp ~/.gitconfig git/.gitconfig
```

`install.sh` symlinks these into `$HOME` on any machine:

```bash
git clone https://github.com/stephcloud/dotfiles.git
cd dotfiles
./install.sh
```

**Important:** `.gitconfig` uses `~`-relative paths (not hardcoded usernames) for `signingkey` and `allowedSignersFile`, so it's portable across machines. Verified by testing in a throwaway `/tmp/fake-home` directory before trusting it.

## Reproducing this whole setup on a new machine

1. Install `gh` CLI, authenticate with `gh auth login`
2. Clone `dotfiles`, run `./install.sh` to restore shell + Git config shape
3. Generate a **new** signing key on the new machine (keys are not portable/shared across machines for security reasons) — repeat Section 4 above
4. Clone `operations-lab` to continue bootcamp work

## Known limitations

- Signing keys are per-machine. A new machine always needs its own fresh key generated and registered with GitHub — this is intentional, not a bug.
- GitHub Pages deployments can occasionally get stuck in an "errored" state (observed once during this module, in the `stephcloud.github.io` repo, unrelated to `operations-lab`). Fix: toggle the Pages source setting off/on, or push a genuine content change to force a fresh build attempt.
