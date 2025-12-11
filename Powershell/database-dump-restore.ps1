# Script PowerShell para Dump e Restore de Base de Dados
# Autor: Sistema
# Data: $(Get-Date -Format "dd/MM/yyyy")
# Suporta: MySQL, PostgreSQL, SQL Server

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("mysql", "postgresql", "sqlserver")]
    [string]$DatabaseType = "mysql",
    
    [Parameter(Mandatory=$false)]
    [string]$SourceHost = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePort = "",
    
    [Parameter(Mandatory=$true)]
    [string]$SourceDatabase,
    
    [Parameter(Mandatory=$true)]
    [string]$SourceUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePassword,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetHost = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetPort = "",
    
    [Parameter(Mandatory=$true)]
    [string]$TargetDatabase,
    
    [Parameter(Mandatory=$true)]
    [string]$TargetUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetPassword,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = ".\backup",
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteBackupAfter = $false
)

Write-Host "=== Database Dump & Restore Tool ===" -ForegroundColor Green
Write-Host "Tipo de Base de Dados: $DatabaseType" -ForegroundColor Yellow
Write-Host "Base de Origem: $SourceDatabase@$SourceHost" -ForegroundColor Cyan
Write-Host "Base de Destino: $TargetDatabase@$TargetHost" -ForegroundColor Cyan

# Configurações específicas por SGBD
function Get-DatabaseConfig {
    param([string]$dbType)
    
    switch ($dbType) {
        "mysql" {
            return @{
                DefaultPort = "3306"
                DumpCommand = "mysqldump"
                RestoreCommand = "mysql"
                CheckCommand = "mysql"
            }
        }
        "postgresql" {
            return @{
                DefaultPort = "5432"
                DumpCommand = "pg_dump"
                RestoreCommand = "psql"
                CheckCommand = "psql"
            }
        }
        "sqlserver" {
            return @{
                DefaultPort = "1433"
                DumpCommand = "sqlcmd"
                RestoreCommand = "sqlcmd"
                CheckCommand = "sqlcmd"
            }
        }
    }
}

# Função para verificar se as ferramentas estão disponíveis
function Test-DatabaseTools {
    param([hashtable]$config)
    
    Write-Host "`nVerificando ferramentas necessárias..." -ForegroundColor Yellow
    
    $tools = @($config.DumpCommand, $config.RestoreCommand)
    foreach ($tool in $tools) {
        if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "✗ $tool não encontrado!" -ForegroundColor Red
            Write-Host "Instale as ferramentas client do $DatabaseType" -ForegroundColor Yellow
            return $false
        } else {
            Write-Host "✓ $tool encontrado" -ForegroundColor Green
        }
    }
    return $true
}

# Função para criar diretório de backup
function New-BackupDirectory {
    param([string]$path)
    
    if (!(Test-Path $path)) {
        Write-Host "Criando diretório de backup: $path" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# Função para fazer dump da base de dados
function Invoke-DatabaseDump {
    param([hashtable]$config, [string]$backupFile)
    
    Write-Host "`n--- Iniciando Dump da Base de Dados ---" -ForegroundColor Cyan
    
    # Definir porta padrão se não especificada
    $sourcePortParam = if ($SourcePort) { $SourcePort } else { $config.DefaultPort }
    
    try {
        switch ($DatabaseType) {
            "mysql" {
                $dumpCmd = "$($config.DumpCommand) -h$SourceHost -P$sourcePortParam -u$SourceUsername"
                if ($SourcePassword) { $dumpCmd += " -p$SourcePassword" }
                $dumpCmd += " --single-transaction --routines --triggers $SourceDatabase > `"$backupFile`""
            }
            "postgresql" {
                $env:PGPASSWORD = $SourcePassword
                $dumpCmd = "$($config.DumpCommand) -h $SourceHost -p $sourcePortParam -U $SourceUsername -d $SourceDatabase -f `"$backupFile`" --verbose"
            }
            "sqlserver" {
                $dumpCmd = "$($config.DumpCommand) -S $SourceHost,$sourcePortParam -U $SourceUsername -P $SourcePassword -Q `"BACKUP DATABASE [$SourceDatabase] TO DISK = '$backupFile'`""
            }
        }
        
        Write-Host "Executando dump..." -ForegroundColor Yellow
        Write-Host "Comando: $dumpCmd" -ForegroundColor Gray
        
        Invoke-Expression $dumpCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Dump concluído com sucesso!" -ForegroundColor Green
            Write-Host "Arquivo: $backupFile" -ForegroundColor Gray
            return $true
        } else {
            Write-Host "✗ Erro durante o dump!" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Erro durante o dump: $_" -ForegroundColor Red
        return $false
    }
    finally {
        # Limpar variável de ambiente de senha
        if ($DatabaseType -eq "postgresql") {
            Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
        }
    }
}

# Função para fazer restore da base de dados
function Invoke-DatabaseRestore {
    param([hashtable]$config, [string]$backupFile)
    
    Write-Host "`n--- Iniciando Restore da Base de Dados ---" -ForegroundColor Cyan
    
    # Definir porta padrão se não especificada
    $targetPortParam = if ($TargetPort) { $TargetPort } else { $config.DefaultPort }
    
    try {
        switch ($DatabaseType) {
            "mysql" {
                $restoreCmd = "$($config.RestoreCommand) -h$TargetHost -P$targetPortParam -u$TargetUsername"
                if ($TargetPassword) { $restoreCmd += " -p$TargetPassword" }
                $restoreCmd += " $TargetDatabase < `"$backupFile`""
            }
            "postgresql" {
                $env:PGPASSWORD = $TargetPassword
                $restoreCmd = "$($config.RestoreCommand) -h $TargetHost -p $targetPortParam -U $TargetUsername -d $TargetDatabase -f `"$backupFile`""
            }
            "sqlserver" {
                $restoreCmd = "$($config.RestoreCommand) -S $TargetHost,$targetPortParam -U $TargetUsername -P $TargetPassword -Q `"RESTORE DATABASE [$TargetDatabase] FROM DISK = '$backupFile'`""
            }
        }
        
        Write-Host "Executando restore..." -ForegroundColor Yellow
        Write-Host "Comando: $restoreCmd" -ForegroundColor Gray
        
        Invoke-Expression $restoreCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Restore concluído com sucesso!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Erro durante o restore!" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Erro durante o restore: $_" -ForegroundColor Red
        return $false
    }
    finally {
        # Limpar variável de ambiente de senha
        if ($DatabaseType -eq "postgresql") {
            Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
        }
    }
}

# Função principal
function Main {
    # Obter configuração do SGBD
    $config = Get-DatabaseConfig -dbType $DatabaseType
    
    # Verificar ferramentas
    if (!(Test-DatabaseTools -config $config)) {
        Write-Host "Instalação necessária cancelada." -ForegroundColor Red
        return
    }
    
    # Criar diretório de backup
    New-BackupDirectory -path $BackupPath
    
    # Gerar nome do arquivo de backup
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFileName = "${SourceDatabase}_${timestamp}"
    
    switch ($DatabaseType) {
        "mysql" { $backupFileName += ".sql" }
        "postgresql" { $backupFileName += ".sql" }
        "sqlserver" { $backupFileName += ".bak" }
    }
    
    $backupFile = Join-Path $BackupPath $backupFileName
    
    # Solicitar confirmação
    Write-Host "`n--- Confirmação ---" -ForegroundColor Yellow
    Write-Host "Origem: $SourceDatabase ($SourceHost)" -ForegroundColor White
    Write-Host "Destino: $TargetDatabase ($TargetHost)" -ForegroundColor White
    Write-Host "Backup: $backupFile" -ForegroundColor White
    
    $confirmation = Read-Host "`nDeseja continuar? (S/N)"
    if ($confirmation -notlike "S*" -and $confirmation -notlike "s*") {
        Write-Host "Operação cancelada pelo usuário." -ForegroundColor Yellow
        return
    }
    
    # Executar dump
    if (Invoke-DatabaseDump -config $config -backupFile $backupFile) {
        
        # Verificar se arquivo foi criado
        if (Test-Path $backupFile) {
            $fileSize = [math]::Round((Get-Item $backupFile).Length / 1MB, 2)
            Write-Host "Tamanho do backup: ${fileSize}MB" -ForegroundColor Gray
            
            # Executar restore
            if (Invoke-DatabaseRestore -config $config -backupFile $backupFile) {
                Write-Host "`n✓ Operação concluída com sucesso!" -ForegroundColor Green
                
                # Deletar backup se solicitado
                if ($DeleteBackupAfter) {
                    Write-Host "Deletando arquivo de backup..." -ForegroundColor Yellow
                    Remove-Item $backupFile -Force
                    Write-Host "✓ Backup deletado" -ForegroundColor Green
                }
            } else {
                Write-Host "`n✗ Falha no restore!" -ForegroundColor Red
            }
        } else {
            Write-Host "✗ Arquivo de backup não foi criado!" -ForegroundColor Red
        }
    } else {
        Write-Host "`n✗ Falha no dump!" -ForegroundColor Red
    }
}

# Validar parâmetros obrigatórios
if (!$SourceDatabase -or !$SourceUsername -or !$TargetDatabase -or !$TargetUsername) {
    Write-Host "Erro: Parâmetros obrigatórios não fornecidos!" -ForegroundColor Red
    Write-Host "`nUso:" -ForegroundColor Yellow
    Write-Host ".\database-dump-restore.ps1 -DatabaseType mysql -SourceDatabase db_origem -SourceUsername user1 -TargetDatabase db_destino -TargetUsername user2" -ForegroundColor Gray
    Write-Host "`nParâmetros disponíveis:" -ForegroundColor Yellow
    Write-Host "  -DatabaseType: mysql, postgresql, sqlserver" -ForegroundColor Gray
    Write-Host "  -SourceHost, -TargetHost: Endereço do servidor" -ForegroundColor Gray
    Write-Host "  -SourcePort, -TargetPort: Porta do servidor" -ForegroundColor Gray
    Write-Host "  -SourcePassword, -TargetPassword: Senhas" -ForegroundColor Gray
    Write-Host "  -BackupPath: Diretório para backup (padrão: .\backup)" -ForegroundColor Gray
    Write-Host "  -DeleteBackupAfter: Deletar backup após restore" -ForegroundColor Gray
    exit 1
}

# Solicitar senhas se não fornecidas
if (!$SourcePassword) {
    $SourcePassword = Read-Host "Digite a senha da base de origem" -AsSecureString
    $SourcePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePassword))
}

if (!$TargetPassword) {
    $TargetPassword = Read-Host "Digite a senha da base de destino" -AsSecureString
    $TargetPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TargetPassword))
}

# Executar função principal
Main

Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")