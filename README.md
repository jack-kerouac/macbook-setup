1. install Homebrew

## Git
1. `brew install git`
1. Install SSH key (`mkdir .ssh; chmod 755 .ssh`, copy `idrsa` and `idrsa.pub`) 
1. Clone this repo, e.g. into `~/src/macbook-setup`. Manually link all files with `.symlink` extensions:
  - `$ ln -s ~/src/macbook-setup/gitignore.symlink ~/.gitignore`
  - `$ ln -s ~/src/macbook-setup/gitconfig.symlink ~/.gitconfig`
1. `brew install hub`. Enter GH credentials once.

## Fish and Shell
1. `brew install iterm2`
1. `brew install fish`. Set fish shell as default: https://gist.github.com/gagarine/cf3f65f9be6aa0e105b184376f765262
1. [install fisherman](https://github.com/fisherman/fisherman)
1. Install theme 'bob the fish': `fisher install oh-my-fish/theme-bobthefish`, `set -g theme_powerline_fonts no` (to not having to [install a powerline font](https://github.com/oh-my-fish/theme-bobthefish#installation))

## misc
1. .vimrc
1. Install through AppStore: Copy'em Paste


TODOs:
- look into [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)

Brew bundles (`brew leaves`):
- aws-elasticbeanstalk
- awscli
- bower
- c-ares
- cloc
- crowdin
- ext2fuse
- fish
- geoip
- git
- glib
- gnu-sed
- gnutls
- gradle
- grunt-cli
- httpie
- hub
- influxdb
- jq
- ktlint
- libgcrypt
- lua
- macvim
- maven
- mit-scheme
- mysql@5.6
- nginx
- node@10
- node@12
- node@4
- openssl@1.1
- pv
- pyenv
- redis
- rlwrap
- sdedit
- ssh-copy-id
- telnet
- tree
- unrar
- watch
- wget

Brew casks (`brew cask ls`):
- temurin8 (successor of AdoptOpenJDK)
- temurin11 (successor of AdoptOpenJDK)
- banking-4
- calibre
- docker
- firefox
- font-roboto-mono-for-powerline
- intellij-idea
- iterm2
- java
- java8
- ngrok
- portfolioperformance
- postman
- sketchup
- skitch
- skype
- wireshark
