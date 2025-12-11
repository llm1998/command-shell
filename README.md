# Shell Scripts Collection

Esta é uma coleção de scripts úteis em PowerShell e Shell Script para diferentes propósitos.

## 📁 Estrutura do Projeto

```
Shell/
├── README.md
├── Powershell/
│   ├── execute-many-curl-commands.ps1
│   ├── get-windows-key.ps1
│   └── database-dump-restore.ps1
└── ShellScript/
    ├── execute-many-curl-commands.sh
    └── database-dump-restore.sh
```

## 🔧 Scripts Disponíveis

### PowerShell Scripts

#### 1. execute-many-curl-commands.ps1
**Descrição**: Script para executar múltiplos comandos cURL de forma automatizada com tratamento de erros e relatório de execução.

**Funcionalidades**:
- Executa uma lista de comandos cURL sequencialmente
- Tratamento de erros para cada comando
- Relatório final com estatísticas de sucesso/erro
- Confirmação antes da execução
- Verificação automática da disponibilidade do cURL

**Como executar**:
```powershell
# Navegar até a pasta
cd "C:\Shell\Powershell"

# Executar o script
.\execute-many-curl-commands.ps1
```

**Customização**: 
- Edite o array `$curlCommands` para adicionar seus próprios comandos cURL
- Descomente a linha `Start-Sleep` para adicionar pausa entre comandos
- Descomente a linha de salvamento para salvar resultados em arquivos

#### 2. get-windows-key.ps1
**Descrição**: Script para extrair e exibir a chave de produto (Product Key) do Windows instalado no sistema.

**Funcionalidades**:
- Extrai a chave de produto do registro do Windows
- Exibe informações do produto (nome, ID, chave)
- Decodifica a chave do formato binário para texto legível

**Como executar**:
```powershell
# Navegar até a pasta
cd "C:\Shell\Powershell"

# Executar o script
.\get-windows-key.ps1
```

#### 3. database-dump-restore.ps1
**Descrição**: Script completo para fazer dump de uma base de dados e restaurar em outra base automaticamente.

**Funcionalidades**:
- Suporte para MySQL, PostgreSQL e SQL Server
- Dump automático com timestamp
- Restore automático na base de destino
- Verificação de ferramentas necessárias
- Tratamento de erros e rollback
- Opção para deletar backup após restore
- Solicitação segura de senhas
- Relatório detalhado de operações

**Como executar**:
```powershell
# Navegar até a pasta
cd "C:\Shell\Powershell"

# Exemplo MySQL
.\database-dump-restore.ps1 -DatabaseType mysql -SourceDatabase "db_origem" -SourceUsername "user1" -TargetDatabase "db_destino" -TargetUsername "user2"

# Exemplo PostgreSQL
.\database-dump-restore.ps1 -DatabaseType postgresql -SourceHost "192.168.1.100" -SourceDatabase "app_prod" -SourceUsername "admin" -TargetHost "localhost" -TargetDatabase "app_test" -TargetUsername "dev"

# Com parâmetros adicionais
.\database-dump-restore.ps1 -DatabaseType mysql -SourceDatabase "ecommerce" -SourceUsername "root" -TargetDatabase "ecommerce_backup" -TargetUsername "backup_user" -BackupPath "C:\Backups" -DeleteBackupAfter
```

**Parâmetros disponíveis**:
- `-DatabaseType`: mysql, postgresql, sqlserver
- `-SourceHost/-TargetHost`: Endereços dos servidores
- `-SourcePort/-TargetPort`: Portas dos servidores
- `-SourceDatabase/-TargetDatabase`: Nomes das bases
- `-SourceUsername/-TargetUsername`: Usuários
- `-SourcePassword/-TargetPassword`: Senhas (opcional, será solicitado)
- `-BackupPath`: Diretório para backup (padrão: .\backup)
- `-DeleteBackupAfter`: Deletar backup após restore

**Requisitos**:
- Ferramentas client instaladas (mysql, pg_dump, sqlcmd)
- Acesso de leitura na base origem
- Acesso de escrita na base destino

### Shell Scripts (Linux/macOS/WSL)

#### 1. execute-many-curl-commands.sh
**Descrição**: Versão em Shell Script do executor de comandos cURL, compatível com sistemas Unix-like.

**Funcionalidades**:
- Executa uma lista de comandos cURL sequencialmente
- Tratamento de erros para cada comando
- Relatório final com estatísticas
- Confirmação interativa antes da execução
- Verificação automática da disponibilidade do cURL

**Como executar**:
```bash
# Navegar até a pasta
cd "/c/Shell/ShellScript"

# Tornar executável (primeira vez)
chmod +x execute-many-curl-commands.sh

# Executar o script
./execute-many-curl-commands.sh
```

#### 2. database-dump-restore.sh
**Descrição**: Versão em Shell Script do sistema de dump e restore, compatível com sistemas Unix-like.

**Funcionalidades**:
- Suporte para MySQL e PostgreSQL
- Dump automático com timestamp
- Restore automático na base destino
- Interface de linha de comando completa
- Tratamento de erros robusto
- Verificação automática de ferramentas
- Solicitação segura de senhas

**Como executar**:
```bash
# Navegar até a pasta
cd "/c/Shell/ShellScript"

# Tornar executável (primeira vez)
chmod +x database-dump-restore.sh

# Exemplo MySQL
./database-dump-restore.sh -t mysql -sd "db_origem" -su "user1" -td "db_destino" -tu "user2"

# Exemplo PostgreSQL com hosts diferentes
./database-dump-restore.sh -t postgresql -sh "192.168.1.100" -sd "app_prod" -su "admin" -th "localhost" -td "app_test" -tu "dev"

# Com backup customizado
./database-dump-restore.sh -t mysql -sd "ecommerce" -su "root" -td "ecommerce_backup" -tu "backup_user" -bp "/tmp/backups" -d

# Ver ajuda
./database-dump-restore.sh --help
```

**Opções disponíveis**:
- `-t, --type`: mysql, postgresql
- `-sh, --source-host`: Host da base origem
- `-sp, --source-port`: Porta da base origem
- `-sd, --source-db`: Nome da base origem (obrigatório)
- `-su, --source-user`: Usuário da base origem (obrigatório)
- `-sw, --source-pass`: Senha da base origem
- `-th, --target-host`: Host da base destino
- `-tp, --target-port`: Porta da base destino
- `-td, --target-db`: Nome da base destino (obrigatório)
- `-tu, --target-user`: Usuário da base destino (obrigatório)
- `-tw, --target-pass`: Senha da base destino
- `-bp, --backup-path`: Diretório para backup
- `-d, --delete-after`: Deletar backup após restore
- `-h, --help`: Exibir ajuda

**Customização**:
- Edite as configurações padrão no início do script
- Adicione suporte para outros SGBDs modificando as funções

## 🚀 Pré-requisitos

### Para PowerShell Scripts:
- Windows PowerShell 5.1+ ou PowerShell Core 6+
- cURL instalado no sistema (para execute-many-curl-commands.ps1)
- MySQL Client, PostgreSQL Client ou SQL Server Tools (para database-dump-restore.ps1)

### Para Shell Scripts:
- Sistema Unix-like (Linux, macOS, WSL)
- Bash shell
- cURL instalado (`sudo apt install curl` no Ubuntu/Debian)
- MySQL Client (`sudo apt install mysql-client`) ou PostgreSQL Client (`sudo apt install postgresql-client`)

## 📝 Exemplos de Uso

### Testando APIs com cURL
Os scripts de cURL vêm pré-configurados com APIs públicas para teste:
- `https://httpbin.org/get` - API de teste que retorna informações da requisição
- `https://jsonplaceholder.typicode.com/posts/1` - API que retorna dados JSON simulados

### Migrando bases de dados
```powershell
# PowerShell - MySQL para MySQL
.\database-dump-restore.ps1 -DatabaseType mysql -SourceDatabase "prod_db" -SourceUsername "root" -TargetDatabase "staging_db" -TargetUsername "dev"

# PowerShell - PostgreSQL
.\database-dump-restore.ps1 -DatabaseType postgresql -SourceHost "prod-server" -SourceDatabase "app" -SourceUsername "admin" -TargetHost "test-server" -TargetDatabase "app_test" -TargetUsername "testuser"
```

```bash
# Shell Script - Migração completa
./database-dump-restore.sh -t mysql -sh "production.company.com" -sd "ecommerce" -su "readonly" -th "localhost" -td "ecommerce_dev" -tu "developer" -bp "/home/user/backups" -d
```
- `https://httpbin.org/get` - API de teste que retorna informações da requisição
- `https://jsonplaceholder.typicode.com/posts/1` - API que retorna dados JSON simulados

### Migrando bases de dados
```powershell
# PowerShell - MySQL para MySQL
.\database-dump-restore.ps1 -DatabaseType mysql -SourceDatabase "prod_db" -SourceUsername "root" -TargetDatabase "staging_db" -TargetUsername "dev"

# PowerShell - PostgreSQL
.\database-dump-restore.ps1 -DatabaseType postgresql -SourceHost "prod-server" -SourceDatabase "app" -SourceUsername "admin" -TargetHost "test-server" -TargetDatabase "app_test" -TargetUsername "testuser"
```

```bash
# Shell Script - Migração completa
./database-dump-restore.sh -t mysql -sh "production.company.com" -sd "ecommerce" -su "readonly" -th "localhost" -td "ecommerce_dev" -tu "developer" -bp "/home/user/backups" -d
```
```powershell
# PowerShell - executar múltiplos scripts
Get-ChildItem *.ps1 | ForEach-Object { & $_.FullName }
```

```bash
# Bash - executar múltiplos scripts
for script in *.sh; do
    if [ -x "$script" ]; then
        ./"$script"
    fi
done
```

## ⚠️ Importantes

1. **Segurança**: Sempre revise os comandos cURL antes de executar, especialmente ao trabalhar com APIs de produção
2. **Permissões**: Alguns scripts podem precisar de privilégios elevados
3. **Backup**: Faça backup de dados importantes antes de executar scripts que modificam o sistema
4. **Teste**: Teste primeiro em ambiente de desenvolvimento

## 🔄 Conversões Disponíveis

- ✅ PowerShell → Shell Script: `execute-many-curl-commands`
- ✅ PowerShell → Shell Script: `database-dump-restore`
- 🔄 Futuras conversões podem ser adicionadas conforme necessário

### Executando scripts em lote
```powershell
# PowerShell - executar múltiplos scripts
Get-ChildItem *.ps1 | ForEach-Object { & $_.FullName }
```

```bash
# Bash - executar múltiplos scripts
for script in *.sh; do
    if [ -x "$script" ]; then
        ./"$script"
    fi
done
```

## 📚 Recursos Adicionais

- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [cURL Documentation](https://curl.se/docs/)

---

**Autor**: Sistema  
**Data de Criação**: Dezembro 2025  
**Última Atualização**: $(Get-Date -Format "dd/MM/yyyy")