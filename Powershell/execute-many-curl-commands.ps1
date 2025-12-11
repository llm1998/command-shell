# Script PowerShell para executar múltiplos comandos curl
# Autor: Sistema
# Data: $(Get-Date -Format "dd/MM/yyyy")

Write-Host "=== Executor de Comandos CURL ===" -ForegroundColor Green
Write-Host "Iniciando execução dos comandos..." -ForegroundColor Yellow

# Array com os comandos curl a serem executados
# Adicione seus comandos curl aqui, um por linha
$curlCommands = @(
    # APIs públicas simples para testes
    "curl --location 'https://httpbin.org/get'",
    "curl --location 'https://jsonplaceholder.typicode.com/posts/1'"
)

# Função para executar um comando curl e tratar erros
function Execute-CurlCommand {
    param(
        [string]$command,
        [int]$index
    )
    
    Write-Host "`n--- Executando comando $index ---" -ForegroundColor Cyan
    Write-Host "Comando: $command" -ForegroundColor Gray
    
    try {
        # Executa o comando curl
        $result = Invoke-Expression $command
        
        Write-Host "✓ Comando $index executado com sucesso" -ForegroundColor Green
        
        # Opcional: salvar resultado em arquivo
        # $result | Out-File -FilePath "resultado_$index.txt" -Encoding UTF8
        
        return $result
    }
    catch {
        Write-Host "✗ Erro ao executar comando $index`: $_" -ForegroundColor Red
        return $null
    }
}

# Função principal
function Main {
    $totalCommands = $curlCommands.Count
    $successCount = 0
    $errorCount = 0
    
    Write-Host "`nTotal de comandos a executar: $totalCommands" -ForegroundColor White
    
    # Pergunta se o usuário quer continuar
    $confirmation = Read-Host "`nDeseja continuar com a execução? (S/N)"
    if ($confirmation -notlike "S*" -and $confirmation -notlike "s*") {
        Write-Host "Execução cancelada pelo usuário." -ForegroundColor Yellow
        return
    }
    
    # Executa cada comando curl
    for ($i = 0; $i -lt $curlCommands.Count; $i++) {
        $command = $curlCommands[$i].Trim()
        
        # Pula comandos vazios ou comentários
        if ([string]::IsNullOrEmpty($command) -or $command.StartsWith("#")) {
            continue
        }
        
        $result = Execute-CurlCommand -command $command -index ($i + 1)
        
        if ($result -ne $null) {
            $successCount++
        } else {
            $errorCount++
        }
        
        # Pausa opcional entre comandos (descomente se necessário)
        # Start-Sleep -Seconds 1
    }
    
    # Relatório final
    Write-Host "`n=== Relatório de Execução ===" -ForegroundColor Green
    Write-Host "Total de comandos: $totalCommands" -ForegroundColor White
    Write-Host "Sucessos: $successCount" -ForegroundColor Green
    Write-Host "Erros: $errorCount" -ForegroundColor Red
    Write-Host "Execução finalizada!" -ForegroundColor Yellow
}

# Verifica se o curl está disponível
if (!(Get-Command curl -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: curl não encontrado no sistema!" -ForegroundColor Red
    Write-Host "Por favor, instale o curl ou verifique se está no PATH do sistema." -ForegroundColor Yellow
    exit 1
}

# Executa a função principal
Main

# Pausa para ver o resultado (opcional)
Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")