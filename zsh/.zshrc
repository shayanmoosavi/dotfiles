source ~/.zsh_omz
source ~/.zsh_aliases

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# GTK theme
export GTK_THEME=Nordic-bluish-accent-standard-buttons-v40
# export GTK_THEME=Sweet-mars-v40
# export GTK_THEME=Sweet-Dark

# Fastfetch
if [[ $TERM == "xterm-kitty" ]] || [[ $TERM == "wezterm" ]] || [[ $TERM == "xterm-ghostty" ]]; then
    fastfetch --config "$HOME/.config/fastfetch/shayan.jsonc"
elif [[ $(basename $(ps -p $(ps -p $$ -o ppid=) -o args=)) == "konsole" ]]; then
    fastfetch --config "$HOME/.config/fastfetch/shayan.jsonc"
else
    fastfetch --config "$HOME/.config/fastfetch/shayan_simple.jsonc"   
fi

# Starship prompt
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/shayan/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/shayan/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/shayan/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/shayan/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
#
# conda deactivate
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
