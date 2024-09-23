################################################################################
# Name:        .bashrc
# Date:        2024-03-22
# Author:      Amosnimos
# Description: Configures various environment variables, path settings, and key mappings in the Bash shell.
################################################################################

#   ▛▀▖▞▀▖▞▀▖▌ ▌▛▀▖▞▀▖
#   ▙▄▘▙▄▌▚▄ ▙▄▌▙▄▘▌  
# ▗▖▌ ▌▌ ▌▖ ▌▌ ▌▌▚ ▌ ▖
# ▝▘▀▀ ▘ ▘▝▀ ▘ ▘▘ ▘▝▀ 

# === RETHINK EVERYTHINK ! ===

# Make sure the keyboard is set to english us
setxkbmap us

# Define color constants
ps_yellow=$'\[\e[0;33m\]'
ps_green=$'\[\e[1;32m\]'
ps_red=$'\[\e[0;91m\]'
ps_blue=$'\[\e[0;94m\]'
ps_white=$'\[\e[0;97m\]'
ps_reset=$'\[\e[0m\]'

Yellow=$'\e[0;33m'
Green=$'\e[1;32m'
Red=$'\e[0;91m'
Blue=$'\e[0;94m'
White=$'\e[0;97m'
bold=$'\e[1m'
uline=$'\e[4m'
Reset=$'\e[0m'

# Variables
onlycap="true"

user_bin=$HOME/bin # Scripts for general task for general users and systems.
personal_bin=$HOME/mybin # Scripts for user specefic needs made for the user specefic system and not to be used widly.
user_lib=$HOME/lib # Scripts that needs to be sourced inside other scripts to be used
user_lib=$HOME/exe # Scripts that are compiled (closed source)

color_prompt="true"
ps1_color=$ps_yellow

# Help function for the alias file
alias_help() {
    local file="$ALIAS_PATH"
    if [ -f "$file" ]; then
        while read -r line; do
            if [[ "$line" == alias* ]]; then
                local alias_name="$(echo "$line" | cut -d '=' -f 1 | sed 's/alias //')"
                local alias_desc="$(echo "$line" | cut -d '#' -f 2- | sed 's/^[[:space:]]*//')"
                if [[ "$alias_name" == "\"$1"* ]]; then
                    echo "$alias_name: ${alias_desc:-Description not available.}"
                fi
            fi
        done < "$file"
    else
        echo "Alias file not found."
    fi
    if [[ -z $1 ]];then 
        echo ""
        echo -e "${Yellow}TIP: Use alias_help followed by a query string to filter and display aliases. For example, alias_help <query> will show aliases that start with <query>.${Reset}"
    fi
}

# Help function for .bashrc
bashrc_help() {
    local script_path="$HOME/.bashrc"
    local section=""
    local description=""
    local in_section=false

    while IFS= read -r line; do
        if [[ $line == \#* ]]; then
            if [[ $line == \#\[*\]* ]]; then
                # Found a section title
                if $in_section; then
                    echo "[$section]: $description"
                fi
                section=$(echo "$line" | sed 's/#\[//;s/\]//')
                description=""
                in_section=true
            else
                # Found a comment within a section
                description="$description $line"
            fi
        elif [[ $line == "" && $in_section ]]; then
            # End of section
            echo "[$section]: $description"
            in_section=false
        fi
    done < "$script_path"
}

# Default Config
if [ -d "$user_bin" ]; then
    # add bins to PATH
    PATH="$user_bin:$PATH"
    PATH="$personal_bin:$PATH"
fi

# The lib folder countains bash scripts taht are meant to be sourced inside other bashscripts and usually not use directly
if [[ -d "$user_lib" ]]; then
    PATH="$user_lib:$PATH"
fi

if [[ -d "$user_exe" ]]; then
    PATH="$user_exe:$PATH"
fi

# Export variables
export ALIAS_PATH=$HOME/alias.sh
export EDITOR=nano

# Custom Config
shopt -s cdspell

# Source files
source $user_bin/basic_utility
source $ALIAS_PATH
# Source personal scripts
source $HOME/bin/func

# Prompt
if [[ "$color_prompt" == "true" ]]; then
    PS1="${symbol_line}[$ps1_color\w$ps_reset]:"
else
    PS1='[\w]:'
fi

# XTerm Title
case "$TERM" in
    xterm*|rxvt*)
        PS1="${symbol_line}[$ps1_color\w$ps_reset]:"
        ;;
    *)
        ;;
esac

#DEBUG print current keyboard layout
#setxkbmap -query
#setxkbmap us

# If x is enable
if [ -n "$DISPLAY" ]; then
    # if not in tty
    if [[ "$TERM" != "xterm" && "$TERM" != "xterm-256color" ]]; then
        xmodmap -e "keycode 62 = 0x007e"
        setxkbmap -option caps:escape
        # Warning script for battery warning
        warning_status
        export screen_width=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1 | sed -n '1p')
        export screen_height=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2 | sed -n '1p')
        export screen_res=$(echo "$screen_width X $screen_height")

        # IBus setup
        export GTK_IM_MODULE=ibus
        export XMODIFIERS=@im=ibus
        export QT_IM_MODULE=ibus
    fi
#else
#    # generate text log to record tty session
#    script tty_$(day)_$(printf %02d $((RANDOM % 100))).txt
fi

#script tty_$(day).txt

# Export OLDPWD to store the previous working directory for the 'cd -' command. The script sources the stored OLDPWD when starting a new terminal session, ensuring 'cd -' returns to the last directory. The trap command updates the OLDPWD variable with the current directory when closing the terminal, ensuring continuity between sessions.

#pwd_tmp="/var/tmp/.store_oldpwd.tmp" # temporary file path

# Export OLDPWD when starting a new terminal session
#if [ -f $pwd_tmp ]; then
#    source $pwd_tmp || echo "failed to source $pwd_tmp file for permanent OLDPWD variable."
#    #if [[ -w $pwd_tmp ]]; then
#        #del $pwd_tmp -m
#    #else
#    #    echo "ERROR: Could not delete $pwd_tmp, User does not have write access to $pwd_tmp. (Tips: use 'sudo', or 'chmod')"
#    #fi
#fi

#trap '[ "$PWD" != "$HOME" ] && echo "export OLDPWD="$(pwd) > $pwd_tmp' EXIT
#if [[ $USER == "amos" ]]; then
#    trap 'echo "export OLDPWD="$(pwd) > $pwd_tmp' EXIT # Trap the EXIT signal to store the current working directory in a temporary file
#fi

# MinGW path
export PATH="/path/to/MinGW/bin:$PATH"

# Qt library path
export PKG_CONFIG_PATH="/path/to/Qt/lib/pkgconfig:$PKG_CONFIG_PATH"
