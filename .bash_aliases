# .bash_aliases

# --- Ajuda ---
alias ajuda='cat ~/.bash_aliases'

# --- Navegação e Listagem ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- Git  ---
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'


# --- Docker ---
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'
alias dku='docker compose up -d'     # Docker Compose UP (Keep going)
alias dkd='docker compose down'      # Docker Compose Down
alias dkb='docker compose build'     # Docker Compose Build
alias dklog='docker compose logs -f' # Docker Compose Logs (Follow)
alias dklc='docker compose logs --tail 100 -f' # Logs com limite
alias dkexec='docker compose exec'   # Atalho para executar comandos no container
alias dcps='docker compose ps'       # Ver o status do compose