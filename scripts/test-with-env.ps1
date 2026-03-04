# Script PowerShell pour charger les variables d'environnement et lancer les tests
# Usage: .\scripts\test-with-env.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  CHARGEMENT DES VARIABLES D'ENVIRONNEMENT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Charger le fichier .env
$envFile = ".\.env"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Supprimer les guillemets si présents
            $value = $value -replace '^["'']|["'']$', ''
            
            # Définir la variable d'environnement pour ce processus
            [Environment]::SetEnvironmentVariable($name, $value, [EnvironmentVariableTarget]::Process)
            Write-Host "✓ $name = $value" -ForegroundColor Green
        }
    }
    Write-Host ""
} else {
    Write-Host "⚠ Fichier .env non trouvé" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  EXÉCUTION DES TESTS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Lancer les tests Maven
mvn test -Dtest=PasswordHashTest
