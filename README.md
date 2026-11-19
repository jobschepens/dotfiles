# Personal zsh dotfiles

Small zsh configuration for WSL/Linux. It is kept as symlinks from this repository;
the cross-platform agent, git, and AI-provider configuration lives in the separate
`chezmoi` repository.

## Files

| File | Purpose |
|---|---|
| `zshrc` | Interactive zsh configuration; oh-my-zsh is loaded when installed. |
| `zprofile` | Login-shell PATH, pyenv, and SSH-agent setup. |
| `aliases` | Small set of shell aliases. |
| `install.sh` | Links the three files above into `$HOME` and installs oh-my-zsh if missing. |

Ruby/Rails, VS Code, and macOS SSH snippets from the original Le Wagon template were
removed; they are still available in the git history if ever needed.

## Install

```bash
./install.sh
exec zsh
```

`install.sh` only creates symlinks and installs oh-my-zsh/its optional plugins. It does not
use `sudo`, install system packages, or touch SSH/VS Code configuration.

## RAMSES / shared clusters

Do **not** use this repository on RAMSES. Use the `chezmoi` setup described in
`CHEZMOI_CHEATSHEET.md` §13 (managed `.bashrc` and agent configs) or a minimal
`~/.zshrc` without the WSL/VS Code assumptions. In particular, do not run
`install.sh` there.

If you want oh-my-zsh on RAMSES, install it manually without changing your shell or
overwriting `.zshrc`, then use a minimal cluster-specific `~/.zshrc`:

```bash
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```
