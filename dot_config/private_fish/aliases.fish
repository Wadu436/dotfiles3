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
alias reload="source ~/.config/fish/config.fish"
alias peel="exit" # We just take the shell off
alias home="cd ~"
alias gitroot="cd (git rev-parse --show-toplevel)"
alias pip='uv pip'
abbr --add activate 'source .venv/bin/activate.fish'

alias repos="cd ~/Repositories; ls -d * | cdfzf"
alias config="cd ~/.config/; ls -d * | cdfzf"

alias yay="paru"

## Aliases
# Filesystem and stuff
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'

alias cat='bat -p'

alias vi='nvim'
alias vim='nvim'

alias eza='eza -F -gh --time-style=long-iso'
alias ls='eza' # add file type extension
alias la='eza -a' # show hidden files
alias ll='eza -l' # long listing format
alias lt='eza -T' # Tree format

alias massmurder='docker stop $(docker ps -a -q)'
alias exterminatus='massmurder && docker rm $(docker ps -a -q)'

alias awslocal="AWS_REGION=local AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test aws --endpoint-url=http://localhost:4566"

## Abbreviations
abbr --add h "history | grep"
abbr --add gs "git status"
abbr --add gpl "git pull"
abbr --add gps "git push"
abbr --add gpsu "git push -u origin"
abbr --add gpp "git pull && git push"
abbr --add ga "git add"
abbr --add gcl "git clone"
abbr --add gc "git checkout"
abbr --add gcb "git checkout -b"
abbr --add gcm "git commit -S -m"
abbr --add gfa "git fetch --all"

# Docker
abbr --add dcu 'docker compose up'
abbr --add dcub 'docker compose up --build'
abbr --add dcd 'docker compose down'
abbr --add dcstop 'docker compose stop'
abbr --add dcstart 'docker compose start'

# abbreviations for various programs
abbr --add c "code ."
abbr --add cu "cursor ."
abbr --add z zellij
abbr --add tf terraform
abbr --add tg terragrunt
