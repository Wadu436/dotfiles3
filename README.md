# Warre's Dotfiles

## Requirements

- Required for these dotfiles

```sh
sudo pacman -Sy git jujutsu chezmoi starship eza fish fzf
```

- Extra useful utilities

```sh
sudo pacman -Sy fd ripgrep which
```

## Set up on new computer

1. Initialize chezmoi + clone the repo

```sh
chezmoi init --ssh git@github.com:Wadu436/dotfiles3.git
```

2. Enter configuration variables

3. Apply the configuration files

```sh
chezmoi apply
```

## Update

To load any changes in the tracked configuration files into the repo, run `chezmoi re-add`
