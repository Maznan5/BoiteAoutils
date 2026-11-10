
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



# ==========================================
# BOITE A OUTILS - SURVEILLANCE SYSTEME
# Fonction : Surveillance de la memoire vive (RAM)
# ==========================================

Write-Host "`n--- MEMOIRE VIVE (RAM) ---" -ForegroundColor Yellow

# Recuperation des informations sur le systeme d'exploitation
try {
    $os = Get-CimInstance Win32_OperatingSystem

    # Calcul de la memoire totale, disponible et utilisee (conversion en Go)
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)

    # Calcul du pourcentage d'utilisation de la RAM
    $usageRAM = [math]::Round(($usedRAM / $totalRAM) * 100, 2)

    # Affichage des resultats
    Write-Host "Memoire totale : $totalRAM Go"
    Write-Host "Memoire utilisee : $usedRAM Go"
    Write-Host "Memoire disponible : $freeRAM Go"
    Write-Host "Utilisation : $usageRAM %"
}
catch {
    # Gestion des erreurs lors de la recuperation des informations
    Write-Host "Erreur lors de la recuperation des informations RAM." -ForegroundColor Red
}