#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Add Defaults
BROWSER=/usr/bin/firefox
EDITOR=/usr/bin/nano

# set a fancy prompt
# thanks to https://gist.github.com/transat/6694554
LBLUE=$'\e[36;40m'
PURPLE=$'\e[35;40m'
GREEN=$'\e[32;40m'
ORANGE=$'\e[33;40m'
YELLOW=$'\e[37;40m'
PINK=$'\e[31;40m'

debug()
{
  echo -n $'\e[0m';
}
trap debug DEBUG

function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local gitcolour="nothing to commit:$YELLOW"
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local gitcolour="untracked:$PINK"
        else
            local gitcolour="branch:$LBLUE"
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n "$gitcolour $branch"
    fi
}

# Colour your prompt

function _prompt_command() {
    PS1='\n\n\[$PINK\]\u \[$LBLUE\]on \[$PURPLE\]\d \[$LBLUE\]at \[$ORANGE\]\@ \[$LBLUE\]in \[$GREEN\]\w \[$ORANGE\]`_git_prompt` \n\[$GREEN\]>> \[$YELLOW\]'
}

export PROMPT_COMMAND=_prompt_command


screenfetch -D "Arch Linux"
