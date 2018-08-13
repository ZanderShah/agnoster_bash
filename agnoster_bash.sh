#!/usr/bin/bash

# Agnoster BASH Theme
# 
# Author: H@di(info@hadisafari.ir)
# 
# Usage:    1. set a powerline-compatible font for terminal
#           2. append this file to your ~/.bash_profile
# 
# • powerline-compatible fonts: https://github.com/powerline/fonts/tree/master/SourceCodePro
# • Monoco powerline-compatible font: https://gist.github.com/rogual/6824790627960fc93077
# • agnoster.zsh-theme: https://github.com/agnoster/agnoster-zsh-theme


PROMPT_COLOR="\[\e[1;2m\]"

function get_git_stat {
    if [[ $(git rev-parse --git-dir 2>/dev/null | wc -l) == 0 ]]; then
        echo 0 # not a git repo
    else
        if [[ $(git status --porcelain 2>/dev/null | wc -l) != 0 ]]; then
            echo 2 # modified
        elif [[ $(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null | wc -l) != 0 ]]; then
            if [[ $(git rev-list HEAD@{upstream}..HEAD 2>/dev/null | wc -l) != 0 && $(git rev-list HEAD..HEAD@{upstream} 2>/dev/null | wc -l) != 0 ]]; then
                echo 5 # diverged
            elif [[ $(git rev-list HEAD@{upstream}..HEAD 2>/dev/null | wc -l) != 0 ]]; then
                echo 3 # ahead
            elif [[ $(git rev-list HEAD..HEAD@{upstream} 2>/dev/null | wc -l) != 0 ]]; then
                echo 4 # behind
            else
                echo 1 # clean
            fi
        else
            echo 1 # clean
        fi
    fi
}

function is_git_detached {
    if [[ $(git rev-parse --abbrev-ref HEAD 2>/dev/null) == "HEAD" ]]; then
        echo 1
    else
        echo 0
    fi
}

function get_fg {
    echo "\[\e[38;5;${1}m\]"
}

function get_bg {
    echo "\[\e[48;5;${1}m\]"
}

function ps1_gen {
    retval=$?
    GIT_STAT=$(get_git_stat)
    git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_head_sh1=$(git rev-parse --verify HEAD 2>/dev/null)

    SEGMENT_SEPARATOR=$'\ue0b0'
    PLUSMINUS=$'\u00b1'
    BRANCH=$'\ue0a0'
    DETACHED=$'\u27a6'
    CROSS=$'\u2718'
    LIGHTNING=$'\u26a1'
    GEAR=$'\u2699'
    PUSH=$'\u21d1'
    PULL=$'\u21d3'
    MERGE=$'\u2694'

    STAT_COLOR=232
    VIRTUALENV_COLOR=18
    DIR_COLOR=24
    GIT_COLOR=30
    FG_DEF=256
    NO_COLOR="\[\e[0;39;49m\]"

    if [[ $retval != 0 ]]; then
        prompt_stat="`get_fg 1`${CROSS}`get_fg $FG_DEF` "
    else
        prompt_stat=""
    fi
    if [[ $(jobs -l | wc -l) != 0 ]]; then
        prompt_stat="${prompt_stat}${GEAR}  "
    fi
    if [[ $UID == 0 ]]; then
        prompt_stat="${prompt_stat}${LIGHTNING} "
    fi
    prompt_stat="${prompt_stat}\u"

    if [[ $VIRTUAL_ENV ]]; then
        prompt_virtualenv="`basename $VIRTUAL_ENV`"
    fi

    prompt_dir="\W"

    if [[ $GIT_STAT != 0 ]]; then
        if [[ $(is_git_detached) == 1 ]]; then
            prompt_git="${DETACHED} ${git_head_sh1::7}"
        else
            prompt_git="${BRANCH} ${git_branch}"
        fi
        if [[ $GIT_STAT == 3 ]]; then
            prompt_git="${prompt_git}${PUSH}"
        elif [[ $GIT_STAT == 4 ]]; then
            prompt_git="${prompt_git}${PULL}"
        elif [[ $GIT_STAT == 5 ]]; then
            prompt_git="${prompt_git}${MERGE} "
        fi
        if [[ $GIT_STAT == 1 ]]; then
            GIT_COLOR=28
        elif [[ $GIT_STAT == 2 ]]; then
            GIT_COLOR=52
        else
            GIT_COLOR=3
        fi
    fi

    if [[ $prompt_stat != "" ]]; then
        prompt_stat="`get_bg $STAT_COLOR``get_fg $FG_DEF`${prompt_stat}`get_fg $STAT_COLOR`"
    fi
    if [[ $prompt_virtualenv != "" ]]; then
        prompt_virtualenv="`get_bg $VIRTUALENV_COLOR`${SEGMENT_SEPARATOR}`get_fg $FG_DEF` ${prompt_virtualenv}`get_fg $VIRTUALENV_COLOR`"
    fi
    if [[ $prompt_dir != "" ]]; then
        prompt_dir="`get_bg $DIR_COLOR`${SEGMENT_SEPARATOR}`get_fg $FG_DEF` ${prompt_dir}`get_fg $DIR_COLOR`"
    fi
    if [[ $prompt_git != "" ]]; then
        prompt_git="`get_bg $GIT_COLOR`${SEGMENT_SEPARATOR}`get_fg $FG_DEF` ${prompt_git}`get_fg $GIT_COLOR`"
    fi
    prompt_end="`get_bg 0`${SEGMENT_SEPARATOR}${NO_COLOR} "

    PS1="${prompt_stat}${prompt_virtualenv}${prompt_dir}${prompt_git}${prompt_end}"

    unset SEGMENT_SEPARATOR
    unset PLUSMINUS
    unset BRANCH
    unset DETACHED
    unset CROSS
    unset LIGHTNING
    unset GEAR
    unset retval
    unset git_head_sh1
    unset git_branch
    unset prompt_retval
    unset prompt_virtualenv
    unset prompt_git
    unset prompt_stat
    unset prompt_end
    unset STAT_COLOR
    unset VIRTUALENV_COLOR
    unset DIR_COLOR
    unset GIT_COLOR
    unset NO_COLOR
    unset FG_DEF
}

PS2="${PROMPT_COLOR}${PS2}\e[0m"
PS3="${PROMPT_COLOR}${PS3}\e[0m"
PS4="${PROMPT_COLOR}${PS4}\e[0m"
PROMPT_COMMAND="ps1_gen;$PROMPT_COMMAND"
