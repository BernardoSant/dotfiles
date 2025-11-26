#!/bin/bash
DOTFILES_DIR="$HOME/dotfiles"

echo "🔧 Iniciando setup do ambiente..."

# --- Aliases ---
ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
if ! grep -q ".bash_aliases" "$HOME/.bashrc"; then
    echo "if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi" >> "$HOME/.bashrc"
fi

# --- Starship (O Prompt Inteligente) ---
if ! command -v starship &> /dev/null; then
    echo "🚀 Instalando Starship..."
    # Instala o binário em /usr/local/bin (padrão) ou ~/.local/bin
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
else
    echo "🚀 Starship já instalado."
fi

# --- Configuração do Shell ---
# Adiciona o gancho do Starship ao final do .bashrc
if ! grep -q "starship init bash" "$HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
fi

echo "✅ Ambiente pronto! Reinicie o terminal."