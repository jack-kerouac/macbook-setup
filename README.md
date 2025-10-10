# How to set up my MacBook

## Basic MacBook setup
- language: English, country: Germany,
- create account
- setup TouchID
- setup disk encryption using FileVault, note down recovery code
- Pair BT peripherals
- Adjust mouse tracking speed
- Adjust keyboard repeat rate to fastest
- Change resolution of second display
- Disable Siri and Apple Intelligence
- Add quad4 DNS servers through [adding profile](https://docs.quad9.net/Setup_Guides/MacOS/Big_Sur_and_later_%28Encrypted%29/), then check on https://on.quad9.net/.

## Homebrew
- Install homebrew
- `$ brew bundle install` to install all packages from `Brewfile` (see: https://docs.brew.sh/Brew-Bundle-and-Brewfile)

## Git & Github
- Github CLI
  - `$ gh auth login`, git protocol: HTTPS
- clone this repo: `$ gh repo clone jack-kerouac/macbook-setup`
- symlink .gitconfig and .gitignore
  - `$ ln -s ~/src/macbook-setup/gitignore.symlink ~/.gitignore`
  - `$ ln -s ~/src/macbook-setup/gitconfig.symlink ~/.gitconfig`
- symlink .vimrc: `$ ln -s ~/src/macbook-setup/vimrc.symlink ~/.vimrc`

## Fish shell and iterm2
- Symlink fish config from macbook-setup: `$ ln -s ~/src/macbook-setup/fish/fish.config.symlink ~/.config/fish/fish.config`
- Change login shell to fish (https://fishshell.com/docs/current/)
  - `$ echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells`
  - `$ chsh -s /opt/homebrew/bin/fish`

- Iterm2 config
  - make it the default terminal (through menu)
  - Settings -> General -> Closing -> Quit when all windows are closed
  - Settings -> General -> Closing -> Disable all confirmations...
  - Settings -> Appearance -> Theme -> Dark

## Other applications config
- Copy 'Em Paste: enable it to launch after login (in preferences)
