# Script PowerShell para executar multiplos comandos curl
# Autor: Sistema  
# Data: $(Get-Date -Format "dd/MM/yyyy")

Write-Host "=== Executor de Comandos CURL ===" -ForegroundColor Green
Write-Host "Iniciando execucao dos comandos..." -ForegroundColor Yellow

# Array com os comandos curl a serem executados
# Adicione seus comandos curl aqui, um por linha
$curlCommands = @(
    # APIs publicas simples para testes
    "curl --location 'https://httpbin.org/get'",
    "curl --location 'https://jsonplaceholder.typicode.com/posts/1'"
)

# Funcao para executar um comando curl e tratar erros
function Execute-CurlCommand {
    param(
        [string]$command,
        [int]$index
    )
    
    Write-Host "`n--- Executando comando $index ---" -ForegroundColor Cyan
    Write-Host "Comando: $command" -ForegroundColor Gray
    
    try {
        # Executa o comando curl
        $result = cmd /c $command
        
        Write-Host "Comando $index executado com sucesso" -ForegroundColor Green
        
        # Opcional: salvar resultado em arquivo
        # $result | Out-File -FilePath "resultado_$index.txt" -Encoding UTF8
        
        return $result
    }
    catch {
        Write-Host "Erro ao executar comando $index - $_" -ForegroundColor Red
        return $null
    }
}

# Funcao principal
function Main {
    $totalCommands = $curlCommands.Count
    $successCount = 0
    $errorCount = 0
    
    Write-Host "`nTotal de comandos a executar: $totalCommands" -ForegroundColor White
    
    # Pergunta se o usuario quer continuar
    $confirmation = Read-Host "`nDeseja continuar com a execucao? (S/N)"
    if ($confirmation -notlike "S*" -and $confirmation -notlike "s*") {
        Write-Host "Execucao cancelada pelo usuario." -ForegroundColor Yellow
        return
    }
    
    # Executa cada comando curl
    for ($i = 0; $i -lt $curlCommands.Count; $i++) {
        $command = $curlCommands[$i].Trim()
        
        # Pula comandos vazios ou comentarios
        if ([string]::IsNullOrEmpty($command) -or $command.StartsWith("#")) {
            continue
        }
        
        $result = Execute-CurlCommand -command $command -index ($i + 1)
        
        if ($result -ne $null) {
            $successCount++
        } else {
            $errorCount++
        }
        
        # Pausa opcional entre comandos (descomente se necessario)
        # Start-Sleep -Seconds 1
    }
    
    # Relatorio final
    Write-Host "`n=== Relatorio de Execucao ===" -ForegroundColor Green
    Write-Host "Total de comandos: $totalCommands" -ForegroundColor White
    Write-Host "Sucessos: $successCount" -ForegroundColor Green
    Write-Host "Erros: $errorCount" -ForegroundColor Red
    Write-Host "Execucao finalizada!" -ForegroundColor Yellow
}

# Verifica se o curl esta disponivel
if (!(Get-Command curl -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: curl nao encontrado no sistema!" -ForegroundColor Red
    Write-Host "Por favor, instale o curl ou verifique se esta no PATH do sistema." -ForegroundColor Yellow
    exit 1
}

# Executa a funcao principal
Main

# Pausa para ver o resultado (opcional)
Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
Read-Host