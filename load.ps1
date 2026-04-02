# Usage: .\load.ps1 init\fichier.sql [autre-fichier.sql ...]

$composeFile = ".\docker-compose.dev.yml"
$dbService = "db"
$dbUser = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "controltower_user" }
$dbName = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "controltower" }

if ($args.Count -eq 0) {
    Write-Host "Usage: .\load.ps1 init\fichier.sql [autre-fichier.sql ...]" -ForegroundColor Yellow
    exit 1
}

$dbContainerId = docker compose -f $composeFile ps -q $dbService
if (-not $dbContainerId) {
    Write-Host "Service '$dbService' introuvable. Lance d'abord: docker compose -f $composeFile up -d" -ForegroundColor Red
    exit 1
}

$isRunning = docker inspect -f "{{.State.Running}}" $dbContainerId 2>$null
if ($isRunning -ne "true") {
    Write-Host "Le conteneur DB n'est pas en cours d'execution. Lance: docker compose -f $composeFile up -d" -ForegroundColor Red
    exit 1
}

foreach ($file in $args) {
    # Autorise: init\x.sql, database\init\x.sql, ou chemin absolu/relatif existant
    $resolvedPath = $null
    if (Test-Path $file) {
        $resolvedPath = $file
    } elseif (Test-Path ".\database\$file") {
        $resolvedPath = ".\database\$file"
    } elseif (Test-Path ".\database\init\$file") {
        $resolvedPath = ".\database\init\$file"
    }

    if (-not $resolvedPath) {
        Write-Host " $file introuvable" -ForegroundColor Red
        exit 1
    }

    Write-Host " $file..." -ForegroundColor Yellow
    Get-Content $resolvedPath -Raw -Encoding UTF8 | docker compose -f $composeFile exec -T $dbService psql -U $dbUser -d $dbName

    if ($LASTEXITCODE -eq 0) {
        Write-Host " $file OK" -ForegroundColor Green
    } else {
        Write-Host " $file ERREUR" -ForegroundColor Red
        exit 1
    }
}