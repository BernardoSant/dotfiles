DOTFILES_DIR="$HOME/dotfiles"

echo "🔧 Instalando Dotfiles do Bernardo..."

ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"

# Garante que o .bashrc carregue os aliases
if ! grep -q ".bash_aliases" "$HOME/.bashrc"; then
    echo "if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi" >> "$HOME/.bashrc"
fi

echo "✅ Dotfiles instalados com sucesso!"