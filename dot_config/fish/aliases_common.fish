#alias editaliases="nvim ~/.config/fish/aliases.fish; source ~/.config/fish/aliases.fish"
#alias editconfig="nvim ~/.config/fish/config.fish; source ~/.config/fish/config.fish"
function fishcfg
    cd ~/.config/fish/
    set -l output (ls *.fish | bfzf $argv)
    cd - # go back to the prev dir
    if test -n "~/.config/fish/$output"
        $EDITOR ~/.config/fish/$output
        source ~/.config/fish/config.fish
    end
end

abbr --add jjtrunk 'jj git fetch && jj new -r "trunk()"'

alias reload="source ~/.config/fish/config.fish"
alias home="cd ~"
alias gitroot="cd (jj root)"
alias pip='uv pip'
abbr --add activate 'source .venv/bin/activate.fish'

alias repos="cd ~/Repositories; ls -d * | cdfzf"
alias config="cd ~/.config/; ls -d * | cdfzf"

## Aliases
# Filesystem and stuff
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
if test (uname) = Linux
    alias ps='ps auxf'
else
    alias ps='ps aux'
end
alias ping='ping -c 10'

alias cat='bat -p'

alias vi='nvim'
alias vim='nvim'

alias gl='glab'

alias eza='eza -F -gh --time-style=long-iso'
alias ls='eza' # add file type extension
alias la='eza -a' # show hidden files
alias ll='eza -l' # long listing format
alias lt='eza -T' # Tree format

alias massmurder='docker stop $(docker ps -a -q)'
alias exterminatus='massmurder && docker rm $(docker ps -a -q)'

alias awslocal="AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test aws --endpoint-url=http://localhost:4566"

## Abbreviations
abbr --add h "history | grep"

# Docker
abbr --add dc 'docker compose'
abbr --add dcu 'docker compose up'
abbr --add dcub 'docker compose up --build'
abbr --add dcd 'docker compose down'
abbr --add dcstop 'docker compose stop'
abbr --add dcstart 'docker compose start'
abbr --add dcl 'docker compose logs --follow'

# abbreviations for various programs
abbr --add c "code ."
abbr --add cu "cursor ."
abbr --add z zellij
abbr --add tf tofu
abbr --add tg terragrunt

abbr --add cm chezmoi
