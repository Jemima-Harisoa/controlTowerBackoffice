# Script de build local pour Control Tower Backoffice
# Usage: .\build.ps1 [clean|compile|package|test]

param(
    [string]$Action = "compile"
)

Write-Host "Build Script - Control Tower Backoffice" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Yellow

switch ($Action.ToLower()) {
    "clean" {
        Write-Host "Nettoyage du projet..." -ForegroundColor Green
        mvn clean
    }
    "compile" {
        Write-Host "Compilation du projet..." -ForegroundColor Green
        mvn clean compile
    }
    "package" {
        Write-Host "Packaging du projet (WAR)..." -ForegroundColor Green
        mvn clean package -DskipTests
    }
    "test" {
        Write-Host "Execution des tests..." -ForegroundColor Green
        mvn test
    }
    "full" {
        Write-Host "Build complet avec tests..." -ForegroundColor Green
        mvn clean install
    }
    default {
        Write-Host "Action non reconnue: $Action" -ForegroundColor Red
        Write-Host "Actions disponibles: clean, compile, package, test, full" -ForegroundColor Yellow
        exit 1
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build termine avec succes!" -ForegroundColor Green
} else {
    Write-Host "Erreur durant le build!" -ForegroundColor Red
    exit $LASTEXITCODE
}