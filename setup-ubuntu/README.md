
# 🚀 Guia de Execução

Este projeto utiliza **Ansible Roles** para gerenciar a configuração do ambiente. A grande vantagem dessa estrutura organizada são as **TAGS**, que permitem executar partes específicas da automação sem processar o sistema inteiro.

---

## ⚡ 1. Instalação Rápida (Recomendado)
Para configurar um **PC Novo** do zero, utilize o script de bootstrap. Ele instalará automaticamente o Ansible, o Git e executará todo o fluxo de configuração.

1. Dê permissão de execução ao script:
   ```bash
   chmod +x bootstrap.sh

```

2. Execute o script (não use sudo, ele pedirá a senha quando necessário):
```bash
./bootstrap.sh

```



---

## 🛠️ 2. Execução Manual (Alternativa)

Caso prefira rodar o comando do Ansible manualmente ou esteja depurando o sistema.

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass

```

---

## 🔄 3. Manutenção Inteligente (Uso de Tags)

Não é necessário rodar o playbook inteiro para pequenas alterações. Use as tags para economizar tempo e aplicar mudanças específicas.

### 🟢 Atualizar apenas o VS Code

**Cenário:** Você adicionou uma nova extensão na lista de variáveis e quer aplicá-la, ou precisa reinstalar o editor.

```bash
ansible-playbook -i inventory.ini site.yml --tags "vscode" --ask-become-pass

```

### 🐳 Configurar apenas Docker e Backend

**Cenário:** Você quer garantir que o Docker, Docker Compose e ferramentas de desenvolvimento estão instalados e na versão correta.

```bash
ansible-playbook -i inventory.ini site.yml --tags "docker" --ask-become-pass

```

### 🎨 Atualizar apenas Interface Visual (GUI)

**Cenário:** Você alterou configurações do GNOME, instalou novos temas ou quer atualizar o Ulauncher/Simplenote.

```bash
ansible-playbook -i inventory.ini site.yml --tags "visual" --ask-become-pass

```
