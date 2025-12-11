#!/bin/bash

# Script Shell para executar múltiplos comandos curl
# Autor: Sistema
# Data: $(date +"%d/%m/%Y")

echo "=== Executor de Comandos CURL ==="
echo "Iniciando execução dos comandos..."

# Array com os comandos curl a serem executados
# Adicione seus comandos curl aqui, um por linha
curl_commands=(
    # APIs públicas simples para testes
    "curl --location 'https://httpbin.org/get'"
    "curl --location 'https://jsonplaceholder.typicode.com/posts/1'"
)

# Função para executar um comando curl e tratar erros
execute_curl_command() {
    local command="$1"
    local index="$2"
    
    echo ""
    echo "--- Executando comando $index ---"
    echo "Comando: $command"
    
    if eval "$command"; then
        echo "✓ Comando $index executado com sucesso"
        return 0
    else
        echo "✗ Erro ao executar comando $index"
        return 1
    fi
}

# Função principal
main() {
    local total_commands=${#curl_commands[@]}
    local success_count=0
    local error_count=0
    
    echo ""
    echo "Total de comandos a executar: $total_commands"
    
    # Pergunta se o usuário quer continuar
    echo ""
    read -p "Deseja continuar com a execução? (S/N): " confirmation
    if [[ ! "$confirmation" =~ ^[Ss] ]]; then
        echo "Execução cancelada pelo usuário."
        return
    fi
    
    # Executa cada comando curl
    for i in "${!curl_commands[@]}"; do
        local command="${curl_commands[$i]}"
        
        # Pula comandos vazios ou comentários
        if [[ -z "$command" || "$command" =~ ^# ]]; then
            continue
        fi
        
        if execute_curl_command "$command" $((i + 1)); then
            ((success_count++))
        else
            ((error_count++))
        fi
        
        # Pausa opcional entre comandos (descomente se necessário)
        # sleep 1
    done
    
    # Relatório final
    echo ""
    echo "=== Relatório de Execução ==="
    echo "Total de comandos: $total_commands"
    echo "Sucessos: $success_count"
    echo "Erros: $error_count"
    echo "Execução finalizada!"
}

# Verifica se o curl está disponível
if ! command -v curl &> /dev/null; then
    echo "ERRO: curl não encontrado no sistema!"
    echo "Por favor, instale o curl ou verifique se está no PATH do sistema."
    exit 1
fi

# Executa a função principal
main

# Pausa para ver o resultado (opcional)
echo ""
read -p "Pressione Enter para sair..."