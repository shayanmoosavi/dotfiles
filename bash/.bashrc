# Advanced command-not-found hook
source /usr/share/doc/find-the-command/ftc.bash

# Useful aliases
source ~/.bash_aliases

# GTK theme
# export GTK_THEME=Nordic-bluish-accent-standard-buttons-v40
export GTK_THEME=Sweet-mars-v40

# Intel oneapi init
source /opt/intel/oneapi/setvars.sh intel64 > /dev/null 2>&1
source /opt/intel/oneapi/compiler/latest/env/vars.sh

# Fastfetch
if [[ $TERM == "xterm-kitty" ]] || [[ $TERM == "wezterm" ]]; then
    fastfetch --config shayan.jsonc
elif [[ $(basename $(ps -p $(ps -p $$ -o ppid=) -o args=)) == "konsole" ]]; then
    fastfetch --config shayan.jsonc
else
    fastfetch --config shayan_simple.jsonc    
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/shayan/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/shayan/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/shayan/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/shayan/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda deactivate

eval "$(starship init bash)"
