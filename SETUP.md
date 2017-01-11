# Ubuntu 16.10

```
# basic software
sudo apt update
sudo apt dist-upgrade
sudo apt install git zsh vim tmux terminator feh rofi fonts-font-awesome fonts-powerline


# i3-gaps
# https://github.com/Airblader/i3/wiki/Compiling-&-Installing

## dependencies
sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev

## install
cd ~
git clone https://github.com/Airblader/i3.git i3-gaps
cd i3-gaps
autoreconf --force --install
mkdir build && cd build
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make
sudo make install

## i3blocks-gaps
cd ~
git clone https://github.com/Airblader/i3blocks-gaps.git
cd i3blocks-gaps
make
sudo make install


# install dotfiles
cd ~
git clone https://github.com/andihit/dotfiles.git
cd dotfiles
make git zsh vim tmux i3 terminator
chsh -s $(which zsh)
```