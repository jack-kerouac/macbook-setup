# How to set up my MacBook

## Basic MacBook setup
- language: English, country: Germany, keyboard layout
- WiFi
- create account, timezone
- setup TouchID
- setup disk encryption using FileVault, note down recovery code
- Pair BT peripherals
- Adjust mouse
  - tracking speed: 3rd fastest
  - Secondary Click: Click Right side
- Adjust trackpad
  - tracking speed: 3rd fastest
  - tab to click: true
- Adjust keyboard
  - repeat rate to fastest
  - enable Keyboard navigation
- Clock options: Enable seconds 
- Change resolution of second display
- Disable Siri and Apple Intelligence, remove Spotlight from Menu Bar (settings)
- Add quad4 DNS servers through [adding profile](https://docs.quad9.net/Setup_Guides/MacOS/Big_Sur_and_later_%28Encrypted%29/), then check on https://on.quad9.net/.
- Cleanup dock

## Homebrew
- Install homebrew

## Git & Github
- brew install git
- brew install gh
- Github CLI
  - `$ gh auth login`, git protocol: HTTPS
- clone this repo: `$ gh repo clone jack-kerouac/macbook-setup`
- symlink .gitconfig and .gitignore
  - `$ ln -s ~/src/macbook-setup/gitignore.symlink ~/.gitignore`
  - `$ ln -s ~/src/macbook-setup/gitconfig.symlink ~/.gitconfig`

## Install other packages
- `$ brew bundle install` to install all packages from `Brewfile` (see: https://docs.brew.sh/Brew-Bundle-and-Brewfile)

## VIM
- symlink .vimrc: `$ ln -s ~/src/macbook-setup/vimrc.symlink ~/.vimrc`

## Fish shell and iterm2
- Symlink fish config from macbook-setup: `$ ln -s ~/src/macbook-setup/fish/config.fish.symlink ~/.config/fish/config.fish`
- Change login shell to fish (https://fishshell.com/docs/current/)
  - `$ echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells`
  - `$ chsh -s /opt/homebrew/bin/fish`

- Iterm2 config
  - make it the default terminal (through menu)
  - Settings -> General -> Closing -> Quit when all windows are closed
  - Settings -> General -> Closing -> Disable all confirmations...
  - Settings -> Selection -> Command Selection -> Disable
  - Settings -> Appearance -> Theme -> Dark
  - Settings -> Profiles -> Colors -> Color Preset: Regular. Increase Minimum Contrast to 30.

- Ghostty config
  - `$ mkdir -p ~/.config/ghostty && ln -s ~/src/macbook-setup/ghostty/config.symlink ~/.config/ghostty/config`

## Other applications config
- Copy 'Em Paste: enable it to launch after login (in preferences)
