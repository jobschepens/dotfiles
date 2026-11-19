# Treat `#` as a comment in interactive shells. zsh disables this by default,
# so `ls file  # note` passes "note" to ls instead of ignoring it.
setopt interactivecomments

ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# You can change the theme with another one from https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# Useful oh-my-zsh plugins; ignored when oh-my-zsh is not installed
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search zsh-autosuggestions)

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Disable warning about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Actually load Oh-My-Zsh when it is available
if [ -d "$ZSH" ]; then
  source "${ZSH}/oh-my-zsh.sh"
  unalias rm 2>/dev/null # No interactive rm by default (brought by plugins/common-aliases)
  unalias lt 2>/dev/null # we need `lt` for https://github.com/localtunnel/localtunnel
fi

# Load pyenv (to manage your Python versions)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Load nvm (to manage your node versions)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Call `nvm use` automatically in a directory with a `.nvmrc` file
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &> /dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm > /dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm > /dev/null && load-nvmrc

# Rails and Ruby used the local `bin` folder for binstubs; keep the project-local
# bins first for Node/Ruby projects that still use them.
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding: fall back to C.UTF-8 if en_US.UTF-8 isn't generated on this system.
if locale -a 2>/dev/null | grep -qi '^en_US\\.utf8$'; then
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
else
  export LANG=C.UTF-8
  export LC_ALL=C.UTF-8
fi

if command -v code >/dev/null 2>&1; then
  export EDITOR=code
else
  export EDITOR="${EDITOR:-vim}"
fi

# Load environment variables from ~/.env file
if [ -f "$HOME/.env" ]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# Under WSL, pass the AI provider keys through to Windows processes
# (opencode.exe, codex.exe, claude) launched from this shell. Without this they
# inherit the stale value from the Windows process environment instead of ~/.env.
if grep -qi microsoft /proc/version 2>/dev/null; then
  for var in SAIA_API_KEY BLABLADOR_API_KEY KICONNECT_API_KEY; do
    case ":${WSLENV:-}:" in
      *":$var:"*) ;;
      *) export WSLENV="${WSLENV:+$WSLENV:}$var" ;;
    esac
  done
fi

# User binaries (chezmoi, etc.) — ~/.profile only covers login shells
if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.opencode/bin" ] && [[ ":$PATH:" != *":$HOME/.opencode/bin:"* ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
