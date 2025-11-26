# .bash_aliases

# --- Ajuda ---
alias ajuda='cat ~/.bash_aliases'

# --- Navegação e Listagem ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- Git (Cultura de Compartilhamento) ---
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# --- Docker & Ops (Automação) ---
# Mostra apenas containers rodando de forma limpa
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'