
# ==========================================
# BOITE A OUTILS - SURVEILLANCE SYSTEME
# Fonction : Surveillance du processeur (CPU)
# ==========================================

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
    }
}
catch {
    Write-Host "Erreur lors de la recuperation des informations CPU." -ForegroundColor Red
}
