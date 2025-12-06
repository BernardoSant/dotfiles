
# 🚀 Setup de Ambiente DevOps & Full-Stack (Zsh + Starship + Docker + VSC)

Este guia documenta como transformar sua máquina Ubuntu/Linux em uma estação de trabalho de desenvolvimento de alta performance, utilizando o script de automação `setup_environment.sh` (V5.0).

## 🎯 Objetivo

Automatizar a instalação e configuração de todas as ferramentas essenciais (Docker, Zsh, Starship, VS Code e Just) e corrigir problemas de permissão para garantir um *workflow* *plug-and-play*.

-----

## 1\. ⚙️ Pré-requisitos

  * Sistema Operacional: **Ubuntu/Debian**
  * Acesso à Internet e privilégios `sudo`.

-----

## 2\. ⚡ Execução da Automação (Método Sênior)

Para evitar erros e garantir que o script tenha as permissões necessárias para instalar ferramentas de sistema (`apt`), execute o procedimento abaixo.

### Passo A: Baixar e Dar Permissão

1.  **Baixe o Script:** Garanta que o arquivo `setup_environment.sh` esteja no seu diretório de trabalho.

2.  **Dê Permissão de Execução:** Você precisa tornar o arquivo executável.

    ```bash
    chmod +x setup_environment.sh
    ```

### Passo B: Executar o Setup

Execute o script de automação. Ele pedirá sua senha algumas vezes (para `sudo` e `chsh`).

```bash
./setup_environment.sh
```

### O que acontece durante a execução:

  * **Instalação:** Docker Engine, Docker CLI (com auto-correção de falhas), VS Code, Zsh/Oh My Zsh, Starship, e o gerenciador de comandos **Just**.
  * **Configuração:** Adiciona seu usuário ao grupo `docker` e configura o Zsh para evitar avisos de segurança (`compinit`).

-----

## 3\. 🏁 Conclusão e Ativação Final

O script finaliza o setup de software, mas as **permissões de grupo** e o **novo *shell* (Zsh)** só são ativados após um novo login.

### Passo C: Reinicialização Obrigatória

Você deve reiniciar o sistema para garantir que as permissões do grupo `docker` sejam carregadas corretamente, resolvendo o problema de **`permission denied`** de forma definitiva.

```bash
sudo reboot
```

### Passo D: Testes de Verificação

Após reiniciar, abra o terminal e confirme se tudo funciona **sem `sudo`**:

| Teste | Comando | Resultado Esperado |
| :--- | :--- | :--- |
| **Shell/Prompt** | Abrir Terminal | O prompt **Starship** (`✅❯` ou `❌❯`) é exibido. |
| **Docker** | `docker ps` | Exibe a lista de contêineres (sem `permission denied`). |
| **Produtividade** | `j update-system` | O comando deve iniciar a atualização do `apt`. |

