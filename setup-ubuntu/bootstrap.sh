#!/bin/bash
set -e  # Para o script se houver qualquer erro

# Cores para logs bonitos
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 🚀 Iniciando o Bootstrap do Setup (Modo Sênior) ===${NC}"

# 1. Verificação de Segurança (Não rodar como root)
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}❌ Por favor, NÃO rode este script como root (sudo).${NC}"
  echo "Rode apenas: ./bootstrap.sh"
  echo "O script pedirá sua senha quando necessário."
  exit 1
fi

# 2. Atualizar apt e instalar Ansible (se não existir)
echo -e "${GREEN}📦 Verificando dependências...${NC}"
if ! command -v ansible &> /dev/null; then
    echo "Ansible não encontrado. Instalando..."
    sudo apt update
    sudo apt install -y software-properties-common ansible git curl
else
    echo "✅ Ansible já está instalado."
fi

# 3. Verificar se o arquivo inventory existe
if [ ! -f "inventory.ini" ]; then
    echo -e "${RED}❌ Erro: 'inventory.ini' não encontrado.${NC}"
    echo "Você está na pasta correta do projeto?"
    exit 1
fi

# 4. Executar o Playbook
echo -e "${GREEN}🔥 Executando o Ansible Playbook...${NC}"
echo "Você precisará digitar sua senha de SUDO para as tarefas de administrador."
echo ""

ansible-playbook -i inventory.ini site.yml --ask-become-pass 

echo -e "${GREEN}✅ Setup Finalizado com Sucesso!${NC}"
echo "Recomendação: Reinicie o computador para aplicar todas as mudanças de Shell e Interface."