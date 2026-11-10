# ==========================================
# BOITE A OUTILS - SURVEILLANCE SYSTEME
# Fonction : Surveillance du processeur (CPU)
# Option   : -Journal pour enregistrer les mesures dans un fichier log
# ==========================================

param(
    [switch]$Journal,
    [string]$JournalPath
)

# Fichier journal par defaut : surveillance.log a cote du script
if (-not $JournalPath) {
    $dossier = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
    $JournalPath = Join-Path $dossier "surveillance.log"
}

# Fonction qui ajoute une ligne horodatee au journal (seulement si -Journal est utilise)
function Write-Journal($message) {
    if ($Journal) {
        $ligne = "{0} | {1} | {2}" -f (Get-Date -Format "dd/MM/yyyy HH:mm:ss"), $env:COMPUTERNAME, $message
        Add-Content -Path $JournalPath -Value $ligne -Encoding UTF8
    }
}

Clear-Host

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       SURVEILLANCE DU SYSTEME" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n--- PROCESSEUR (CPU) ---" -ForegroundColor Yellow

try {
    $cpu = Get-CimInstance Win32_Processor

    foreach ($processor in $cpu) {
        Write-Host "Nom : $($processor.Name)"
        Write-Host "Nombre de coeurs : $($processor.NumberOfCores)"
        Write-Host "Utilisation : $($processor.LoadPercentage) %"

        Write-Journal ("CPU | {0} | {1} coeurs | {2} %" -f $processor.Name.Trim(), $processor.NumberOfCores, $processor.LoadPercentage)
    }
}
catch {
    Write-Host "Erreur lors de la recuperation des informations CPU." -ForegroundColor Red
    Write-Journal "ERREUR | CPU | $($_.Exception.Message)"
}

if ($Journal) {
    Write-Host "`nJournal mis a jour : $JournalPath" -ForegroundColor Green
}