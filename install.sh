# actualizacion inicial
sudo dnf update -y

# instalar utilidades
sudo dnf install \
  sway \
  kitty \
  tmux \
  neovim \
  git \
  zsh \
  firefox \
  fuzzel \
  wl-clipboard

sudo dnf install \
  bat \
  tree \
  unzip \
  gcc \
  make \
  jq

# cambiar shell
chsh -s $(which zsh)

# configurar terminal por defecto
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config

# cambiar en config
set $term kitty
# cambiar teclado
input "type:keyboard" {
    xkb_layout latam
}

swaymsg reload

# dejar sway por defecto
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi

#instalar homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# instalar oh_my_zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#instalar powerlevel10k
git clone --depth=1 \
https://github.com/romkatv/powerlevel10k.git \
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

ZSH_THEME="powerlevel10k/powerlevel10k"

# instalar yazi
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

brew install yazi

brew install \
  fd \
  ripgrep \
  eza \
  bat \
  zoxide \
  ffmpegthumbnailer 

ya pkg add yazi-rs/plugin:git
ya pkg add yazi-rs/plugin:diff

# instalar docker
sudo dnf install docker docker-compose

sudo usermod -aG docker $USER  

sudo systemctl enable --now docker

# utilidades
brew install terminal-browser \
  fzf \
  go \
  gh \
  lazygit \
  lazydocker \
  btop
