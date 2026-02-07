# Script de développement Control Tower
# Usage: .\dev.ps1 [start|stop|restart|logs|build|clean]

param(
    [string]$Action = "start"
)

Write-Host "🚀 Control Tower - Environnement de développement" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Yellow

switch ($Action.ToLower()) {
    "start" {
        Write-Host "📦 Démarrage de l'environnement de développement..." -ForegroundColor Green
        Write-Host "1. Build du WAR..." -ForegroundColor Yellow
        mvn clean package -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Erreur lors du build Maven!" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "2. Démarrage des conteneurs..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml up -d
        
        Write-Host "✅ Environnement de développement démarré!" -ForegroundColor Green
        Write-Host "📱 Application: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "🗄️  Adminer: http://localhost:8081" -ForegroundColor Cyan
        Write-Host "💾 PostgreSQL: localhost:5432" -ForegroundColor Cyan
        Write-Host "" 
        Write-Host "📝 Pour voir les logs: .\dev.ps1 logs" -ForegroundColor Yellow
    }
    
    "stop" {
        Write-Host "⏹️  Arrêt de l'environnement de développement..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml down
        Write-Host "✅ Environnement arrêté!" -ForegroundColor Green
    }
    
    "restart" {
        Write-Host "🔄 Redémarrage après modification du code..." -ForegroundColor Yellow
        Write-Host "1. Build du WAR..." -ForegroundColor Yellow
        mvn clean package -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Erreur lors du build Maven!" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "2. Redémarrage de l'application..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml restart app
        Write-Host "✅ Application redémarrée!" -ForegroundColor Green
    }
    
    "logs" {
        Write-Host "📋 Logs de l'application..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml logs -f app
    }
    
    "build" {
        Write-Host "🔨 Build du projet..." -ForegroundColor Yellow
        mvn clean package
    }
    
    "clean" {
        Write-Host "🧹 Nettoyage complet..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml down -v
        mvn clean
        Write-Host "✅ Nettoyage terminé!" -ForegroundColor Green
    }
    
    "status" {
        Write-Host "📊 État de l'environnement..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml ps
        Write-Host ""
        Write-Host "📁 WAR généré:" -ForegroundColor Yellow
        if (Test-Path "target/controlTowerBackoffice.war") {
            $size = (Get-Item "target/controlTowerBackoffice.war").Length
            Write-Host "✅ target/controlTowerBackoffice.war ($([math]::round($size/1MB, 2)) MB)" -ForegroundColor Green
        } else {
            Write-Host "❌ WAR non trouvé (lancez: .\dev.ps1 build)" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "❌ Action non reconnue: $Action" -ForegroundColor Red
        Write-Host "Actions disponibles: start, stop, restart, logs, build, clean, status" -ForegroundColor Yellow
    }
}