# Usage: .\load.ps1 fichier1.sql fichier2.sql

foreach ($file in $args) {
    Write-Host " $file..." -ForegroundColor Yellow
    Get-Content ".\database\$file" -Raw -Encoding UTF8 | docker exec -i mysql mysql -u root iran_actu
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " $file OK" -ForegroundColor Green
    } else {
        Write-Host " $file ERREUR" -ForegroundColor Red
        exit 1
    }
}