
# Versão 8.0: God Mode (Kernel, Tiling, Performance & Boot Fix)

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
ZSHRC_FILE="$HOME/.zshrc"

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}🚀 INICIANDO SETUP v8.0 (GOD MODE)${NC}"
echo -e "${GREEN}=====================================================${NC}"

# --- 1. BASE SYSTEM ---

install_base_tools() {
    echo -e "${GREEN}🔧 Atualizando sistema e instalando base...${NC}"
    sudo apt update && sudo apt upgrade -y
    # Dependências para Pop Shell, Alacritty e Compilação
    sudo apt install zsh curl git just ca-certificates gnupg lsb-release wget software-properties-common node-typescript make dconf-cli uuid-runtime libglib2.0-dev -y
    echo -e "${GREEN}✅ Ferramentas base instaladas.${NC}"
}

# --- 2. KERNEL & BOOT FIX (NOVO) ---

install_xanmod_kernel() {
    if grep -q "WSL" /proc/version || [ -f /.dockerenv ]; then
        echo -e "${YELLOW}⚠️ Ambiente virtualizado. Pulando Kernel XanMod.${NC}"
        return
    fi
    if dpkg -l | grep -q linux-xanmod; then
        echo "🏎️ Kernel XanMod já instalado."
    else
        echo -e "${BLUE}🏎️ Instalando Kernel XanMod LTS...${NC}"
        wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
        echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
        sudo apt update
        sudo apt install linux-xanmod-lts -y
        echo -e "${GREEN}✅ Kernel XanMod instalado.${NC}"
    fi

    # FIX DO GRUB (Para lembrar da escolha do Kernel)
    echo -e "${BLUE}🔧 Configurando GRUB para lembrar a escolha de Kernel (SaveDefault)...${NC}"
    sudo cp /etc/default/grub /etc/default/grub.bak
    sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
    if ! grep -q "GRUB_SAVEDEFAULT=true" /etc/default/grub; then
        echo "GRUB_SAVEDEFAULT=true" | sudo tee -a /etc/default/grub
    fi
    sudo update-grub
    echo -e "${GREEN}✅ GRUB configurado. Selecione o XanMod uma vez e ele lembrará.${NC}"
}

# --- 3. PERFORMANCE TUNING (NOVO) ---

optimize_performance() {
    echo -e "${BLUE}⚡ Aplicando otimizações de memória (Swappiness)...${NC}"
    # Reduz o uso de Swap (disco) e prioriza RAM
    echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-sudo-performance.conf
    echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-sudo-performance.conf
    sudo sysctl -p /etc/sysctl.d/99-sudo-performance.conf
    echo -e "${GREEN}✅ Otimizações aplicadas.${NC}"
}

# --- 4. TILING & UX (POP SHELL + ATALHOS) ---

install_pop_shell() {
    echo -e "${BLUE}🪟 Configurando Pop Shell e Atalhos...${NC}"
    
    # Instala Pop Shell se não existir
    if ! gnome-extensions list | grep -q "pop-shell@system76.com"; then
        echo "📥 Baixando Pop Shell..."
        mkdir -p /tmp/pop-shell-install
        git clone https://github.com/pop-os/shell.git /tmp/pop-shell-install
        curr_dir=$(pwd)
        cd /tmp/pop-shell-install
        sh -c 'make local-install'
        cd $curr_dir
    fi

    # FIX DE CONFLITOS (Remove Tiling Assistant)
    gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null
    gnome-extensions enable pop-shell@system76.com 2>/dev/null
    dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default true

    # CONFIGURAÇÃO DE ATALHOS (Pin / Always on Top)
    echo -e "${YELLOW}📌 Configurando atalho Super+T (Always on Top)...${NC}"
    gsettings set org.gnome.desktop.wm.keybindings always-on-top "['<Super>t']"
    # Opcional: Atalho para manter em todos os workspaces (Sticky)
    gsettings set org.gnome.desktop.wm.keybindings always-on-visible-workspace "['<Super><Shift>t']"

    echo -e "${GREEN}✅ Pop Shell ativo e atalhos configurados.${NC}"
}

install_alacritty() {
    if ! command -v alacritty &> /dev/null; then
        echo -e "${BLUE}📺 Instalando Alacritty...${NC}"
        sudo add-apt-repository ppa:aslatter/ppa -y
        sudo apt update
        sudo apt install alacritty -y
    fi

    echo -e "${BLUE}⚙️ Configurando Alacritty (No Decorations)...${NC}"
    mkdir -p ~/.config/alacritty
    cat << EOF > ~/.config/alacritty/alacritty.toml
[window]
decorations = "None"
startup_mode = "Maximized"
dynamic_title = true
opacity = 0.95

[font]
size = 12.0

[scrolling]
history = 10000
EOF
}

# --- 5. DEV TOOLS ---

install_docker_engine() {
    if command -v docker &> /dev/null; then return; fi
    echo -e "${GREEN}🐳 Instalando Docker...${NC}"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker $USER
}

validate_docker_cli() {
    if ! command -v docker &> /dev/null; then sudo apt install docker-ce-cli -y; fi
}

install_vscode() {
    if command -v code &> /dev/null; then return; fi
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update && sudo apt install code -y
}

# --- 6. SHELL CONFIG (ZSH + STARSHIP) ---

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

install_starship() {
    if ! command -v starship &> /dev/null; then sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y; fi
}

install_plugins() {
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    fi
}

configure_global_just() {
    cat << EOF > ~/.just_global
update-system:
    sudo apt update && sudo apt upgrade -y
reload-shell:
    source ~/.zshrc
clean-docker:
    docker container prune -f
    docker image prune -a -f
EOF
}

configure_zshrc() {
    PLUGINS_CONFIG="plugins=(\ngit\ndocker\ndocker-compose\nzsh-autosuggestions\nzsh-syntax-highlighting\n)"
    cp $ZSHRC_FILE $ZSHRC_FILE.tmp
    sed -i "/^plugins=(/c\\$PLUGINS_CONFIG" $ZSHRC_FILE.tmp
    if ! grep -q 'starship init zsh' $ZSHRC_FILE.tmp; then echo 'eval "$(starship init zsh)"' >> $ZSHRC_FILE.tmp; fi
    if ! grep -q 'alias j=' $ZSHRC_FILE.tmp; then echo 'alias j="just -f ~/.just_global"' >> $ZSHRC_FILE.tmp; fi
    mv $ZSHRC_FILE.tmp $ZSHRC_FILE
}

configure_starship_toml() {
    mkdir -p ~/.config
    cat << EOF > ~/.config/starship.toml
format = """\$all"""
[status]
symbol = '❌'
success_symbol = '✅'
disabled = false
[directory]
truncation_length = 3
style = "bold cyan"
[git_branch]
symbol = "🌿"
EOF
}

fix_zsh_permissions() {
    zsh -c "compaudit 2>/dev/null | xargs sudo chmod g-w,o-w"
}

set_default_shell() {
    if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then chsh -s $(which zsh); fi
}

# --- EXECUÇÃO PRINCIPAL ---

install_base_tools
install_xanmod_kernel      # GRUB Fix incluído aqui
optimize_performance       # Otimização de RAM (Swappiness)
install_pop_shell          # Tiling Fix + Atalho Super+T
install_alacritty
install_docker_engine
validate_docker_cli
install_vscode
install_oh_my_zsh
install_starship
install_plugins
configure_global_just
configure_zshrc
configure_starship_toml
fix_zsh_permissions
set_default_shell

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}🎉 SETUP v8.0 COMPLETO: A MÁQUINA ESTÁ PRONTA!${NC}"
echo -e "1. ${RED}REINICIE O SISTEMA AGORA (sudo reboot)${NC}."
echo -e "2. ${YELLOW}IMPORTANTE:${NC} Na tela de boot, segure SHIFT, vá em 'Advanced' e escolha o XanMod."
echo -e "   -> O sistema lembrará dessa escolha para sempre."
echo -e "3. Use ${YELLOW}Super+T${NC} para fixar janelas no topo."
echo -e "${GREEN}=====================================================${NC}\n"