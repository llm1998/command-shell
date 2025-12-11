#!/bin/bash

# Script Shell para Dump e Restore de Base de Dados
# Autor: Sistema
# Data: $(date +"%d/%m/%Y")
# Suporta: MySQL, PostgreSQL

# Configurações padrão
DATABASE_TYPE="mysql"
SOURCE_HOST="localhost"
SOURCE_PORT=""
SOURCE_DATABASE=""
SOURCE_USERNAME=""
SOURCE_PASSWORD=""
TARGET_HOST="localhost"
TARGET_PORT=""
TARGET_DATABASE=""
TARGET_USERNAME=""
TARGET_PASSWORD=""
BACKUP_PATH="./backup"
DELETE_BACKUP_AFTER=false

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Função para exibir ajuda
show_help() {
    echo -e "${YELLOW}=== Database Dump & Restore Tool ===${NC}"
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  -t, --type TYPE          Tipo de base de dados (mysql, postgresql)"
    echo "  -sh, --source-host HOST  Host da base de origem (padrão: localhost)"
    echo "  -sp, --source-port PORT  Porta da base de origem"
    echo "  -sd, --source-db DB      Nome da base de origem (obrigatório)"
    echo "  -su, --source-user USER  Usuário da base de origem (obrigatório)"
    echo "  -sw, --source-pass PASS  Senha da base de origem"
    echo "  -th, --target-host HOST  Host da base de destino (padrão: localhost)"
    echo "  -tp, --target-port PORT  Porta da base de destino"
    echo "  -td, --target-db DB      Nome da base de destino (obrigatório)"
    echo "  -tu, --target-user USER  Usuário da base de destino (obrigatório)"
    echo "  -tw, --target-pass PASS  Senha da base de destino"
    echo "  -bp, --backup-path PATH  Diretório para backup (padrão: ./backup)"
    echo "  -d, --delete-after       Deletar backup após restore"
    echo "  -h, --help               Exibir esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 -t mysql -sd db_origem -su user1 -td db_destino -tu user2"
}

# Função para processar argumentos
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                DATABASE_TYPE="$2"
                shift 2
                ;;
            -sh|--source-host)
                SOURCE_HOST="$2"
                shift 2
                ;;
            -sp|--source-port)
                SOURCE_PORT="$2"
                shift 2
                ;;
            -sd|--source-db)
                SOURCE_DATABASE="$2"
                shift 2
                ;;
            -su|--source-user)
                SOURCE_USERNAME="$2"
                shift 2
                ;;
            -sw|--source-pass)
                SOURCE_PASSWORD="$2"
                shift 2
                ;;
            -th|--target-host)
                TARGET_HOST="$2"
                shift 2
                ;;
            -tp|--target-port)
                TARGET_PORT="$2"
                shift 2
                ;;
            -td|--target-db)
                TARGET_DATABASE="$2"
                shift 2
                ;;
            -tu|--target-user)
                TARGET_USERNAME="$2"
                shift 2
                ;;
            -tw|--target-pass)
                TARGET_PASSWORD="$2"
                shift 2
                ;;
            -bp|--backup-path)
                BACKUP_PATH="$2"
                shift 2
                ;;
            -d|--delete-after)
                DELETE_BACKUP_AFTER=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Argumento desconhecido: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# Função para obter configuração do SGBD
get_database_config() {
    case "$DATABASE_TYPE" in
        "mysql")
            DEFAULT_PORT="3306"
            DUMP_COMMAND="mysqldump"
            RESTORE_COMMAND="mysql"
            CHECK_COMMAND="mysql"
            ;;
        "postgresql")
            DEFAULT_PORT="5432"
            DUMP_COMMAND="pg_dump"
            RESTORE_COMMAND="psql"
            CHECK_COMMAND="psql"
            ;;
        *)
            echo -e "${RED}Tipo de base de dados não suportado: $DATABASE_TYPE${NC}"
            exit 1
            ;;
    esac
}

# Função para verificar ferramentas
test_database_tools() {
    echo -e "${YELLOW}Verificando ferramentas necessárias...${NC}"
    
    local tools=("$DUMP_COMMAND" "$RESTORE_COMMAND")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}✗ $tool não encontrado!${NC}"
            echo -e "${YELLOW}Instale as ferramentas client do $DATABASE_TYPE${NC}"
            return 1
        else
            echo -e "${GREEN}✓ $tool encontrado${NC}"
        fi
    done
    return 0
}

# Função para criar diretório de backup
create_backup_directory() {
    if [[ ! -d "$BACKUP_PATH" ]]; then
        echo -e "${YELLOW}Criando diretório de backup: $BACKUP_PATH${NC}"
        mkdir -p "$BACKUP_PATH"
    fi
}

# Função para solicitar senha
read_password() {
    local prompt="$1"
    local password
    echo -n "$prompt: "
    read -s password
    echo
    echo "$password"
}

# Função para fazer dump da base de dados
database_dump() {
    local backup_file="$1"
    
    echo -e "${CYAN}--- Iniciando Dump da Base de Dados ---${NC}"
    
    # Definir porta padrão se não especificada
    local source_port_param="${SOURCE_PORT:-$DEFAULT_PORT}"
    
    case "$DATABASE_TYPE" in
        "mysql")
            local dump_cmd="$DUMP_COMMAND -h$SOURCE_HOST -P$source_port_param -u$SOURCE_USERNAME"
            if [[ -n "$SOURCE_PASSWORD" ]]; then
                dump_cmd+=" -p$SOURCE_PASSWORD"
            fi
            dump_cmd+=" --single-transaction --routines --triggers $SOURCE_DATABASE > \"$backup_file\""
            ;;
        "postgresql")
            export PGPASSWORD="$SOURCE_PASSWORD"
            local dump_cmd="$DUMP_COMMAND -h $SOURCE_HOST -p $source_port_param -U $SOURCE_USERNAME -d $SOURCE_DATABASE -f \"$backup_file\" --verbose"
            ;;
    esac
    
    echo -e "${YELLOW}Executando dump...${NC}"
    echo -e "${GRAY}Comando: $dump_cmd${NC}"
    
    if eval "$dump_cmd"; then
        echo -e "${GREEN}✓ Dump concluído com sucesso!${NC}"
        echo -e "${GRAY}Arquivo: $backup_file${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro durante o dump!${NC}"
        return 1
    fi
}

# Função para fazer restore da base de dados
database_restore() {
    local backup_file="$1"
    
    echo -e "${CYAN}--- Iniciando Restore da Base de Dados ---${NC}"
    
    # Definir porta padrão se não especificada
    local target_port_param="${TARGET_PORT:-$DEFAULT_PORT}"
    
    case "$DATABASE_TYPE" in
        "mysql")
            local restore_cmd="$RESTORE_COMMAND -h$TARGET_HOST -P$target_port_param -u$TARGET_USERNAME"
            if [[ -n "$TARGET_PASSWORD" ]]; then
                restore_cmd+=" -p$TARGET_PASSWORD"
            fi
            restore_cmd+=" $TARGET_DATABASE < \"$backup_file\""
            ;;
        "postgresql")
            export PGPASSWORD="$TARGET_PASSWORD"
            local restore_cmd="$RESTORE_COMMAND -h $TARGET_HOST -p $target_port_param -U $TARGET_USERNAME -d $TARGET_DATABASE -f \"$backup_file\""
            ;;
    esac
    
    echo -e "${YELLOW}Executando restore...${NC}"
    echo -e "${GRAY}Comando: $restore_cmd${NC}"
    
    if eval "$restore_cmd"; then
        echo -e "${GREEN}✓ Restore concluído com sucesso!${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro durante o restore!${NC}"
        return 1
    fi
}

# Função principal
main() {
    echo -e "${GREEN}=== Database Dump & Restore Tool ===${NC}"
    echo -e "${YELLOW}Tipo de Base de Dados: $DATABASE_TYPE${NC}"
    echo -e "${CYAN}Base de Origem: $SOURCE_DATABASE@$SOURCE_HOST${NC}"
    echo -e "${CYAN}Base de Destino: $TARGET_DATABASE@$TARGET_HOST${NC}"
    
    # Obter configuração do SGBD
    get_database_config
    
    # Verificar ferramentas
    if ! test_database_tools; then
        echo -e "${RED}Instalação necessária cancelada.${NC}"
        return 1
    fi
    
    # Criar diretório de backup
    create_backup_directory
    
    # Gerar nome do arquivo de backup
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_filename="${SOURCE_DATABASE}_${timestamp}.sql"
    local backup_file="$BACKUP_PATH/$backup_filename"
    
    # Solicitar senhas se não fornecidas
    if [[ -z "$SOURCE_PASSWORD" ]]; then
        SOURCE_PASSWORD=$(read_password "Digite a senha da base de origem")
    fi
    
    if [[ -z "$TARGET_PASSWORD" ]]; then
        TARGET_PASSWORD=$(read_password "Digite a senha da base de destino")
    fi
    
    # Solicitar confirmação
    echo ""
    echo -e "${YELLOW}--- Confirmação ---${NC}"
    echo -e "Origem: $SOURCE_DATABASE ($SOURCE_HOST)"
    echo -e "Destino: $TARGET_DATABASE ($TARGET_HOST)"
    echo -e "Backup: $backup_file"
    echo ""
    read -p "Deseja continuar? (S/N): " confirmation
    
    if [[ ! "$confirmation" =~ ^[Ss] ]]; then
        echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
        return 0
    fi
    
    # Executar dump
    if database_dump "$backup_file"; then
        # Verificar se arquivo foi criado
        if [[ -f "$backup_file" ]]; then
            local file_size=$(du -h "$backup_file" | cut -f1)
            echo -e "${GRAY}Tamanho do backup: $file_size${NC}"
            
            # Executar restore
            if database_restore "$backup_file"; then
                echo -e "${GREEN}✓ Operação concluída com sucesso!${NC}"
                
                # Deletar backup se solicitado
                if [[ "$DELETE_BACKUP_AFTER" == true ]]; then
                    echo -e "${YELLOW}Deletando arquivo de backup...${NC}"
                    rm -f "$backup_file"
                    echo -e "${GREEN}✓ Backup deletado${NC}"
                fi
            else
                echo -e "${RED}✗ Falha no restore!${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ Arquivo de backup não foi criado!${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Falha no dump!${NC}"
        return 1
    fi
}

# Processar argumentos
parse_arguments "$@"

# Validar parâmetros obrigatórios
if [[ -z "$SOURCE_DATABASE" || -z "$SOURCE_USERNAME" || -z "$TARGET_DATABASE" || -z "$TARGET_USERNAME" ]]; then
    echo -e "${RED}Erro: Parâmetros obrigatórios não fornecidos!${NC}"
    show_help
    exit 1
fi

# Validar tipo de base de dados
if [[ ! "$DATABASE_TYPE" =~ ^(mysql|postgresql)$ ]]; then
    echo -e "${RED}Erro: Tipo de base de dados não suportado: $DATABASE_TYPE${NC}"
    echo -e "${YELLOW}Tipos suportados: mysql, postgresql${NC}"
    exit 1
fi

# Executar função principal
main

echo ""
read -p "Pressione Enter para sair..."