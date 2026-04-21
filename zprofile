# Setup the PATH for pyenv binaries and shims
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [[ $(uname) == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv 2> /dev/null)"
fi
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

ssh_agent_socket="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.socket"
export SSH_AUTH_SOCK="$ssh_agent_socket"

SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add -l >/dev/null 2>&1
ssh_agent_status=$?
if [ "$ssh_agent_status" -eq 2 ]; then
  if [ -S "$SSH_AUTH_SOCK" ]; then
    rm -f "$SSH_AUTH_SOCK"
  fi
  eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
fi

case "$-" in
  *i*)
    if [ -r /dev/tty ] && [ -f "$HOME/.ssh/id_ed25519_codex" ] && [ -f "$HOME/.ssh/id_ed25519_codex.pub" ]; then
      ssh_public_key="$(cat "$HOME/.ssh/id_ed25519_codex.pub")"
      if ! SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add -L 2>/dev/null | grep -Fqx "$ssh_public_key"; then
        SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add "$HOME/.ssh/id_ed25519_codex" </dev/tty
      fi
      unset ssh_public_key
    fi
    ;;
esac

unset ssh_agent_socket ssh_agent_status
