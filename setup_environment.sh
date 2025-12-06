#!/bin/bash
# [Sudo] Script de Configuração de Ambiente Sênior (Zsh + Starship + Docker + VS Code + XanMod + Alacritty)
# Autor: Sudo (CTO, DevOps e Desenvolvimento Full-Stack)
# Versão 6.0: Performance (XanMod) e Minimalismo (Alacritty)

# Cores e Variáveis
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
ZSHRC_FILE="$HOME/.zshrc"

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}🚀 INICIANDO SETUP DE AMBIENTE (SUDO V6.0 - PERFORMANCE)${NC}"
echo -e "${GREEN}=====================================================${NC}"

# --- FUNÇÕES DE INSTALAÇÃO ---

install_base_tools() {
    echo -e "${GREEN}🔧 Atualizando sistema e instalando ferramentas base...${NC}"
    sudo apt update && sudo apt upgrade -y
    # Adicionado software-properties-common para gerenciar PPAs (necessário para Alacritty)
    sudo apt install zsh curl git just ca-certificates gnupg lsb-release wget software-properties-common -y
    echo -e "${GREEN}✅ Ferramentas base instaladas.${NC}"
}

install_xanmod_kernel() {
    # Verificação de segurança: Não instalar Kernel em WSL ou Containers
    if grep -q "WSL" /proc/version || [ -f /.dockerenv ]; then
        echo -e "${YELLOW}⚠️ Ambiente virtualizado (WSL/Docker) detectado. Pulando instalação do Kernel XanMod.${NC}"
        return
    fi

    if dpkg -l | grep -q linux-xanmod; then
        echo "🏎️ Kernel XanMod já instalado. Pulando..."
        return
    fi

    echo -e "${BLUE}🏎️ Preparando instalação do Kernel XanMod LTS (6.12+)...${NC}"
    
    # Registro da Chave GPG e Repositório
    wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
    echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
    
    sudo apt update
    # Instala a versão LTS (Long Term Support) atual, que engloba a 6.12
    sudo apt install linux-xanmod-lts -y
    
    echo -e "${GREEN}✅ Kernel XanMod LTS instalado. (Requer reboot para ativar).${NC}"
}

install_alacritty() {
    if command -v alacritty &> /dev/null; then
        echo "📺 Alacritty já está instalado. Pulando..."
    else
        echo -e "${BLUE}📺 Instalando Alacritty (Terminal Acelerado por GPU)...${NC}"
        # Usando PPA para garantir versão mais recente que suporte TOML
        sudo add-apt-repository ppa:aslatter/ppa -y
        sudo apt update
        sudo apt install alacritty -y
        echo -e "${GREEN}✅ Alacritty instalado.${NC}"
    fi

    # Configuração do Alacritty (TOML)
    echo -e "${BLUE}⚙️ Configurando Alacritty (decorations = None)...${NC}"
    mkdir -p ~/.config/alacritty
    
    # Cria o arquivo alacritty.toml
    cat << EOF > ~/.config/alacritty/alacritty.toml
[window]
decorations = "None"
startup_mode = "Maximized"
dynamic_title = true

[font]
size = 12.0

[scrolling]
history = 10000
EOF
    echo -e "${GREEN}✅ Configuração do Alacritty aplicada em ~/.config/alacritty/alacritty.toml${NC}"
}

install_docker_engine() {
    if command -v docker &> /dev/null; then
        echo "🐳 Docker Engine já está instalado. Pulando..."
        return
    fi
    
    echo -e "${GREEN}🐳 Instalando Docker Engine via repositórios oficiais...${NC}"
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker Engine instalado e usuário adicionado ao grupo 'docker'.${NC}"
}

validate_and_fix_docker_cli() {
    echo -e "${GREEN}🔍 Validando a instalação do Docker CLI...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ O binário 'docker' não foi encontrado. Tentando reinstalação do CLI...${NC}"
        sudo apt install docker-ce-cli -y
        
        if command -v docker &> /dev/null; then
            echo -e "${GREEN}✅ Reinstalação bem-sucedida. Docker CLI disponível.${NC}"
        else
            echo -e "${RED}🔥 ERRO: Falha ao instalar o Docker CLI. Verifique logs manualmente.${NC}"
        fi
    else
        echo -e "${GREEN}✅ Docker CLI encontrado em: $(which docker).${NC}"
    fi
}

install_vscode() {
    if command -v code &> /dev/null; then
        echo "💻 VS Code já está instalado. Pulando..."
        return
    fi

    echo -e "${GREEN}💻 Instalando Visual Studio Code via repositório...${NC}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt update
    sudo apt install code -y
    echo -e "${GREEN}✅ VS Code instalado.${NC}"
}

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${GREEN}🐚 Instalando Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "🐚 Oh My Zsh já está instalado. Pulando..."
    fi
}

install_starship() {
    if ! command -v starship &> /dev/null; then
        echo -e "${GREEN}🌠 Instalando Starship (Prompt)...${NC}"
        sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
    else
        echo "🌠 Starship já está instalado. Pulando..."
    fi
}

install_plugins() {
    echo -e "${GREEN}🧩 Instalando plugins essenciais para Dev/DevOps...${NC}"
    
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    fi
    echo -e "${GREEN}✅ Plugins instalados.${NC}"
}

configure_global_just() {
    echo -e "${GREEN}📝 Criando arquivo de comandos globais Just (~/.just_global)...${NC}"
    
    cat << EOF > ~/.just_global
# Comandos de Produtividade Global (Justfile)

update-system:
    sudo apt update && sudo apt upgrade -y

reload-shell:
    source ~/.zshrc

clean-docker:
    docker container prune -f
    docker image prune -a -f

fix-perms:
    sudo chown -R \$USER:\$USER \$HOME

# Checa qual Kernel está rodando
check-kernel:
    uname -r
EOF
    echo -e "${GREEN}✅ ~/.just_global criado.${NC}"
}

configure_zshrc() {
    echo -e "${GREEN}📝 Configurando ~/.zshrc...${NC}"
    PLUGINS_CONFIG="plugins=(\ngit\ndocker\ndocker-compose\nzsh-autosuggestions\nzsh-syntax-highlighting\n)"
    
    cp $ZSHRC_FILE $ZSHRC_FILE.tmp
    sed -i "/^plugins=(/c\\$PLUGINS_CONFIG" $ZSHRC_FILE.tmp

    if ! grep -q 'eval "$(starship init zsh)"' $ZSHRC_FILE.tmp; then
        echo -e '\n# Inicialização do Starship Prompt' >> $ZSHRC_FILE.tmp
        echo 'eval "$(starship init zsh)"' >> $ZSHRC_FILE.tmp
    fi

    if ! grep -q 'alias j=' $ZSHRC_FILE.tmp; then
        echo -e '\n# Alias para comandos globais do Just' >> $ZSHRC_FILE.tmp
        echo 'alias j="just -f ~/.just_global"' >> $ZSHRC_FILE.tmp
    fi

    mv $ZSHRC_FILE.tmp $ZSHRC_FILE
    echo -e "${GREEN}✅ ~/.zshrc configurado.${NC}"
}

configure_starship_toml() {
    echo -e "${GREEN}📝 Criando ~/.config/starship.toml...${NC}"
    mkdir -p ~/.config
    
    cat << EOF > ~/.config/starship.toml
format = """\$all"""

[status]
format = '[\$symbol](\$style)'
symbol = '❌'
success_symbol = '✅'
disabled = false
style = 'bold red'

[directory]
truncation_length = 3
style = "bold cyan"

[git_branch]
symbol = "🌿"
style = "bold purple"

[git_status]
format = '([\$all_status\$ahead_behind](\$style))'
style = "bold green"

[nodejs]
symbol = " "
format = "[\$symbol(\$version)](\$style)"
style = "bold green"

[docker_context]
symbol = "🐳 "
format = "[\$symbol\$context](\$style) "
style = "bold blue"
EOF
    echo -e "${GREEN}✅ Starship.toml criado.${NC}"
}

fix_zsh_permissions() {
    echo -e "${GREEN}🛡️ Corrigindo permissões inseguras do Zsh...${NC}"
    zsh -c "compaudit 2>/dev/null | xargs sudo chmod g-w,o-w"
    echo -e "${GREEN}✅ Permissões corrigidas.${NC}"
}

set_default_shell() {
    if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
        echo -e "${YELLOW}⚠️ MUDANÇA DE SHELL REQUER SENHA: Definindo Zsh como padrão...${NC}"
        chsh -s $(which zsh)
        echo -e "${GREEN}✅ Zsh definido como shell padrão.${NC}"
    fi
}

# --- EXECUÇÃO PRINCIPAL ---
install_base_tools
install_xanmod_kernel      # <<< NOVO: Instala Kernel 6.12+ (LTS)
install_alacritty          # <<< NOVO: Instala e configura Alacritty
install_docker_engine
validate_and_fix_docker_cli 
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
echo -e "${GREEN}🎉 SETUP V6.0 COMPLETO: XANMOD + ALACRITTY INSTALADOS!${NC}"
echo -e "1. ${RED}REINICIE O SISTEMA OBRIGATORIAMENTE (sudo reboot)${NC} para carregar o Kernel XanMod."
echo "2. Abra o Alacritty após o reboot. Ele estará sem bordas (decorations = None)."
echo "3. Verifique o kernel com: ${YELLOW}uname -r${NC} (deve mostrar 'xanmod')."
echo -e "${GREEN}=====================================================${NC}\n"
