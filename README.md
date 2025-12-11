# Shell Scripts Collection

Esta é uma coleção de scripts úteis em PowerShell e Shell Script para diferentes propósitos.

## 📁 Estrutura do Projeto

```
Shell/
├── README.md
├── Powershell/
│   ├── execute-many-curl-commands.ps1
│   └── get-windows-key.ps1
└── ShellScript/
    └── execute-many-curl-commands.sh
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
cd "D:\Workspace\morel_group\Shell\Powershell"

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
cd "D:\Workspace\morel_group\Shell\Powershell"

# Executar o script
.\get-windows-key.ps1
```

**Requisitos**:
- Executar como Administrador (recomendado)
- Sistema Windows

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
cd "/d/Workspace/morel_group/Shell/ShellScript"

# Tornar executável (primeira vez)
chmod +x execute-many-curl-commands.sh

# Executar o script
./execute-many-curl-commands.sh
```

**Customização**:
- Edite o array `curl_commands` para adicionar seus comandos
- Descomente a linha `sleep 1` para adicionar pausa entre comandos

## 🚀 Pré-requisitos

### Para PowerShell Scripts:
- Windows PowerShell 5.1+ ou PowerShell Core 6+
- cURL instalado no sistema (para execute-many-curl-commands.ps1)

### Para Shell Scripts:
- Sistema Unix-like (Linux, macOS, WSL)
- Bash shell
- cURL instalado (`sudo apt install curl` no Ubuntu/Debian)

## 📝 Exemplos de Uso

### Testando APIs com cURL
Os scripts de cURL vêm pré-configurados com APIs públicas para teste:
- `https://httpbin.org/get` - API de teste que retorna informações da requisição
- `https://jsonplaceholder.typicode.com/posts/1` - API que retorna dados JSON simulados

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

## ⚠️ Importantes

1. **Segurança**: Sempre revise os comandos cURL antes de executar, especialmente ao trabalhar com APIs de produção
2. **Permissões**: Alguns scripts podem precisar de privilégios elevados
3. **Backup**: Faça backup de dados importantes antes de executar scripts que modificam o sistema
4. **Teste**: Teste primeiro em ambiente de desenvolvimento

## 🔄 Conversões Disponíveis

- ✅ PowerShell → Shell Script: `execute-many-curl-commands`
- 🔄 Futuras conversões podem ser adicionadas conforme necessário

## 📚 Recursos Adicionais

- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [cURL Documentation](https://curl.se/docs/)

---

**Autor**: Sistema  
**Data de Criação**: Dezembro 2025  
**Última Atualização**: $(Get-Date -Format "dd/MM/yyyy")
