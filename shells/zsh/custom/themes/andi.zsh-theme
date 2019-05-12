#
# Theme based on mitsuhikos prompt: https://github.com/mitsuhiko/dotfiles
#

setopt prompt_subst

export LSCOLORS=ExGxFxDxCxHxHxCbCeEbEb

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[blue]%}git%f:"
ZSH_THEME_GIT_PROMPT_SUFFIX="%B"
ZSH_THEME_GIT_PROMPT_BRANCH=""
ZSH_THEME_GIT_PROMPT_STAGED="%B%{$fg[red]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_SEPARATOR=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="%B%{$fg[green]?%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%B%{$fg[cyan]%}%{+%G%}"

ZSH_THEME_VIRTUALENV_PREFIX=" workon %{$fg[red]%}"
ZSH_THEME_VIRTUALENV_SUFFIX="%f"

# This is the basic prompt that is always printed.  It will be
# enclosed to make it newline.
_ANDI_PROMPT='%B%{$fg[magenta]%}%n%f at %{$fg[yellow]%}%M%f in %{$fg[green]%}%~%f%'

# This is the base prompt that is rendered sync.  It should be
# fast to render as a result.  The extra whitespace before the
# newline is necessary to avoid some rendering bugs.
PROMPT=$'\n'$_ANDI_PROMPT$' \n$%b '
RPROMPT='%B[%*]%b'

# The pid of the async prompt process and the communication file
_ANDI_ASYNC_PROMPT=0
_ANDI_ASYNC_PROMPT_FN="/tmp/.zsh_tmp_prompt_$$"

# Remove the default git var update from chpwd and precmd to speed
# up the shell prompt.  We will do the precmd_update_git_vars in
# the async prompt instead
chpwd_functions=("${(@)chpwd_functions:#chpwd_update_git_vars}")
precmd_functions=("${(@)precmd_functions:#precmd_update_git_vars}")

# Conditionally print command execution time
_ANDI_PROMPT_TIME_TRESHOLD=60

# Store command start time
function _andi_preexec() {
  _andi_cmd_start=$(date +%s)
}

# This here implements the async handling of the prompt.  It
# runs the expensive git parts in a subprocess and passes the
# information back via tempfile.
function _andi_precmd() {
  _andi_rv=$?
  _andi_time_now=$(date +%s)
  if [[ ! -z $_andi_cmd_start ]]; then
    _andi_cmd_duration=$((_andi_time_now - _andi_cmd_start))
    unset _andi_cmd_start # clear start time; required for empty commands
  fi

  function async_prompt() {
    # Run the git var update here instead of in the parent
    precmd_update_git_vars

    #
    echo -n $'\n'$_ANDI_PROMPT$' '$(git_super_status)$(virtualenv_prompt_info) > $_ANDI_ASYNC_PROMPT_FN
    if [[ $_andi_cmd_duration -gt $_ANDI_PROMPT_TIME_TRESHOLD ]]; then
      echo -n " took %{$fg[red]%}$(($_andi_cmd_duration/60))m%f" >> $_ANDI_ASYNC_PROMPT_FN
    fi
    if [[ x$_andi_rv != x0 ]]; then
      echo -n " exited %{$fg[red]%}$_andi_rv%f" >> $_ANDI_ASYNC_PROMPT_FN
    fi
    echo -n $' \n$%b ' >> $_ANDI_ASYNC_PROMPT_FN

    # signal parent
    kill -s USR1 $$
  }

  # If we still have a prompt async process we kill it to make sure
  # we do not backlog with useless prompt things.  This also makes
  # sure that we do not have prompts interleave in the tempfile.
  if [[ "${_ANDI_ASYNC_PROMPT}" != 0 ]]; then
    kill -s HUP $_ANDI_ASYNC_PROMPT >/dev/null 2>&1 || :
  fi

  # start background computation
  async_prompt &!
  _ANDI_ASYNC_PROMPT=$!
}

# This is the trap for the signal that updates our prompt and
# redraws it.  We intentionally do not delete the tempfile here
# so that we can reuse the last prompt for successive commands
function _andi_trapusr1() {
  PROMPT="$(cat $_ANDI_ASYNC_PROMPT_FN)"
  _ANDI_ASYNC_PROMPT=0
  zle && zle reset-prompt
}

# Make sure we clean up our tempfile on exit
function _andi_zshexit() {
  rm -f $_ANDI_ASYNC_PROMPT_FN
}

# Hook our preexec, precmd and zshexit functions and USR1 trap
preexec_functions+=(_andi_preexec)
precmd_functions+=(_andi_precmd)
zshexit_functions+=(_andi_zshexit)
trap '_andi_trapusr1' USR1