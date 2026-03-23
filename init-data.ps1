# ===========================================
# SCRIPT DE RESET DE LA BASE DE DONNÉES (POWERSHELL)
# ===========================================
# Usage: .\reset-db.ps1 [-DataFile "path/to/data.sql"] [-Full] [-Help]
# 
# Options:
#   -DataFile      : Chemin vers le fichier SQL de données (défaut: 12-full-schema-single-airport-test-data.sql)
#   -Full          : Réinitialisation complète (truncate + réinsertion de tous les sprints)
#   -Help          : Affiche ce message
#
# Exemple:
#   .\reset-db.ps1                          # Utilise le fichier par défaut (schéma complet, aéroport unique)
#   .\reset-db.ps1 -DataFile "09-sprint5-min-trajets-test-data.sql"
#   .\reset-db.ps1 -Full                    # Reset complet avec tous les sprints
# ===========================================

param(
    [string]$DataFile = "12-full-schema-single-airport-test-data.sql",
    [switch]$Full = $false,
    [switch]$Help = $false
)

# === AFFICHAGE DE L'AIDE ===
if ($Help) {
    Write-Host "Usage: .\reset-db.ps1 [-DataFile `"path/to/data.sql`"] [-Full]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DataFile      Chemin vers le fichier SQL de données (défaut: 12-full-schema-single-airport-test-data.sql)"
    Write-Host "  -Full          Réinitialisation complète (tous les sprints + test data)"
    Write-Host "  -Help          Affiche ce message"
    Write-Host ""
    Write-Host "Exemples:"
    Write-Host "  .\reset-db.ps1                              # Reset avec schéma complet (aéroport unique)"
    Write-Host "  .\reset-db.ps1 -Full                        # Reset complet"
    Write-Host "  .\reset-db.ps1 -DataFile `"autre-data.sql`"  # Test data personnalisé"
    exit 0
}

# === PARAMÈTRES ===
$PostgresContainer = "controltower_db_dev"
$PostgresUser = "controltower_user"
$PostgresDb = "controltower"
$PostgresPassword = "controltower_pass"

# === FONCTION D'AFFICHAGE ===
function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    
    switch ($Type) {
        "SUCCESS" { Write-Host "[OK] $Message" -ForegroundColor Green }
        "ERROR"   { Write-Host "[ERROR] $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
        "INFO"    { Write-Host "[INFO] $Message" -ForegroundColor Blue }
        "WAITING" { Write-Host "[WAIT] $Message" -ForegroundColor Yellow }
        default   { Write-Host $Message }
    }
}

# === FONCTION POUR EXÉCUTER DU SQL ===
function Execute-SQL {
    param(
        [string]$SqlCommand,
        [string]$Description
    )
    
    Write-Status "$Description..." "WAITING"
    
    try {
        $SqlCommand | docker exec -i $PostgresContainer psql `
            -U $PostgresUser `
            -d $PostgresDb `
            -q 2>$null
        
        Write-Status "$Description" "SUCCESS"
        return $true
    }
    catch {
        Write-Status "Erreur lors de: $Description" "ERROR"
        Write-Status "Détail: $_" "ERROR"
        return $false
    }
}

# === FONCTION POUR EXÉCUTER UN FICHIER SQL ===
function Execute-SQLFile {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    # Construire le chemin complet si nécessaire
    if (-not $FilePath.StartsWith("database/init/") -and -not $FilePath.StartsWith("database\init\")) {
        $FilePath = "database/init/$FilePath"
    }
    
    Write-Status "$Description..." "WAITING"
    
    if (-not (Test-Path $FilePath)) {
        Write-Status "Le fichier '$FilePath' n'existe pas" "ERROR"
        return $false
    }
    
    try {
        Get-Content -Raw $FilePath | docker exec -i $PostgresContainer psql `
            -U $PostgresUser `
            -d $PostgresDb `
            -q 2>$null
        
        Write-Status "$Description" "SUCCESS"
        return $true
    }
    catch {
        Write-Status "Erreur lors de: $Description" "ERROR"
        Write-Status "Détail: $_" "ERROR"
        return $false
    }
}

# === VÉRIFICATIONS PRÉALABLES ===
Write-Status "Vérification des prérequis..." "INFO"
Write-Host ""

# Vérifier Docker
try {
    $null = docker ps 2>$null
}
catch {
    Write-Status "Docker n'est pas installé ou non accessible" "ERROR"
    exit 1
}

# Vérifier le conteneur
if (-not (docker ps | Select-String $PostgresContainer)) {
    Write-Status "Le conteneur '$PostgresContainer' n'est pas en cours d'exécution" "ERROR"
    Write-Status "Lancez: docker-compose -f docker-compose_dev.yml up" "WARNING"
    exit 1
}

Write-Status "Tous les prérequis sont satisfaits" "SUCCESS"
Write-Host ""

# === LOGIC DE RESET ===
if ($Full) {
    Write-Status "MODE RESET COMPLET (tous les sprints)" "WARNING"
    Write-Host ""
    
    # Supprimer les tables
    Write-Status "Suppression des tables existantes..." "INFO"
    
    $truncateTablesSQL = @"
TRUNCATE TABLE IF EXISTS planning_trajet_assignation_historique CASCADE;
TRUNCATE TABLE IF EXISTS vehicule_deplacement_historique CASCADE;
TRUNCATE TABLE IF EXISTS planning_trajet_detail CASCADE;
TRUNCATE TABLE IF EXISTS planning_trajet CASCADE;
TRUNCATE TABLE IF EXISTS reservations CASCADE;
TRUNCATE TABLE IF EXISTS clients CASCADE;
TRUNCATE TABLE IF EXISTS vehicules CASCADE;
TRUNCATE TABLE IF EXISTS lieux CASCADE;
TRUNCATE TABLE IF EXISTS type_clients CASCADE;
TRUNCATE TABLE IF EXISTS sexes CASCADE;
TRUNCATE TABLE IF EXISTS hotel CASCADE;
TRUNCATE TABLE IF EXISTS parametres_configuration CASCADE;
"@
    
    Execute-SQL $truncateTablesSQL "Vidage des tables" | Out-Null
    
    # Réinitialiser les scripts
    Write-Host ""
    Write-Status "Réinitialisation complète de la base..." "INFO"
    
    $Scripts = @(
        @{ File = "03-sprint1_form_reservation.sql"; Desc = "Sprint 1 - Form Reservation" }
        @{ File = "04-sprint2-planification_trajet.sql"; Desc = "Sprint 2 - Planification Trajet" }
        @{ File = "05-sprint3-planning-assignation-detail.sql"; Desc = "Sprint 3 - Planning Assignation" }
        @{ File = "06-sprint3-verify-vehicule-mouvement.sql"; Desc = "Sprint 3 - Vérification Véhicule" }
        @{ File = "10-sprint6-disponibilite-vehicule.sql"; Desc = "Sprint 6 - Disponibilité Horaire" }
        @{ File = "12-full-schema-single-airport-test-data.sql"; Desc = "Schéma complet - Aéroport unique" }
    )
    
    foreach ($script in $Scripts) {
        $resolvedScriptPath = "database/init/$($script.File)"
        if (Test-Path $resolvedScriptPath) {
            Execute-SQLFile $script.File $script.Desc | Out-Null
        }
        else {
            Write-Status "Script non trouvé: $resolvedScriptPath" "WARNING"
        }
    }
}
else {
    Write-Status "MODE RESET MINIMAL (données de test uniquement)" "WARNING"
    Write-Host ""
    
    Write-Status "Suppression des réservations de test..." "INFO"
    
    $deleteSQL = @"
DELETE FROM planning_trajet_detail WHERE reservation_id IN (
    SELECT id FROM reservations WHERE nom LIKE 'TEST_%' OR nom LIKE 'SPRINT%' OR nom LIKE 'FULL_%'
);
DELETE FROM reservations WHERE nom LIKE 'TEST_%' OR nom LIKE 'SPRINT%' OR nom LIKE 'FULL_%';
"@
    
    Execute-SQL $deleteSQL "Suppression des réservations de test" | Out-Null
}

# Ajouter les nouvelles données
Write-Host ""
Write-Status "Insertion des nouvelles données..." "INFO"
Execute-SQLFile $DataFile "Données: $DataFile" | Out-Null

# === STATISTIQUES FINALES ===
Write-Host ""
Write-Status "Statistiques finales:" "INFO"

$statsSQL = @"
SELECT 
    'Utilisateurs' as resource, COUNT(*) as count FROM users
UNION ALL
SELECT 'Hôtels', COUNT(*) FROM hotel
UNION ALL
SELECT 'Clients', COUNT(*) FROM clients
UNION ALL
SELECT 'Réservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'Véhicules', COUNT(*) FROM vehicules
UNION ALL
SELECT 'Lieux', COUNT(*) FROM lieux
UNION ALL
SELECT 'Planning trajets', COUNT(*) FROM planning_trajet
UNION ALL
SELECT 'Détails planning', COUNT(*) FROM planning_trajet_detail
ORDER BY resource;
"@

try {
    $result = $statsSQL | docker exec -i $PostgresContainer psql `
        -U $PostgresUser `
        -d $PostgresDb `
        -t -c "" 2>$null
    
    if ($result) {
        Write-Host $result
    }
}
catch {
    Write-Status "Impossible de récupérer les statistiques" "WARNING"
}

# === FIN ===
Write-Host ""
Write-Status "Reset de la base de données terminé avec succès!" "SUCCESS"
Write-Host ""
Write-Status "Prochaines étapes:" "INFO"
Write-Host "   1. Vérifiez la base via Adminer: http://localhost:8081"
Write-Host "   2. Connectez-vous: Utilisateur=controltower_user, DB=controltower"
Write-Host "   3. Testez l'application: http://localhost:8080"
Write-Host ""