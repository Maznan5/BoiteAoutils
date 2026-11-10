
# ==========================================
# BOITE A OUTILS - SURVEILLANCE SYSTEME
# Fonction : Surveillance CPU, RAM et disques
# ==========================================

Clear-Host

# Fonction d'affichage des titres de sections
function Write-Section {
    param (
        [string]$Title
    )

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
}

# Fonction d'affichage des informations
function Write-Info {
    param (
        [string]$Label,
        [string]$Value
    )

    Write-Host ("  {0,-25} : {1}" -f $Label, $Value)
}

# En-tête principal
Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "              SURVEILLANCE SYSTEME" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host ("  Date du contrôle : {0}" -f (Get-Date -Format "dd/MM/yyyy HH:mm:ss")) -ForegroundColor Gray

# ==========================================
# PROCESSEUR (CPU)
# ==========================================

Write-Section "PROCESSEUR (CPU)"

try {
    $cpu = Get-CimInstance Win32_Processor

    foreach ($processor in $cpu) {
        Write-Info "Nom" $processor.Name
        Write-Info "Nombre de coeurs" $processor.NumberOfCores
        Write-Info "Utilisation" "$($processor.LoadPercentage) %"
    }
}
catch {
    Write-Host "  Erreur lors de la recuperation des informations CPU." -ForegroundColor Red
}

# ==========================================
# MEMOIRE VIVE (RAM)
# ==========================================

Write-Section "MEMOIRE VIVE (RAM)"

try {
    $os = Get-CimInstance Win32_OperatingSystem

    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
    $usageRAM = [math]::Round(($usedRAM / $totalRAM) * 100, 2)

    Write-Info "Memoire totale" "$totalRAM Go"
    Write-Info "Memoire utilisee" "$usedRAM Go"
    Write-Info "Memoire disponible" "$freeRAM Go"
    Write-Host ""

    $ramColor = if ($usageRAM -ge 90) { "Red" } elseif ($usageRAM -ge 75) { "Yellow" } else { "Green" }

    Write-Host ("  Utilisation RAM : {0} %" -f $usageRAM) -ForegroundColor $ramColor
}
catch {
    Write-Host "  Erreur lors de la recuperation des informations RAM." -ForegroundColor Red
}

# ==========================================
# DISQUES
# ==========================================

Write-Section "UTILISATION DES DISQUES"

try {
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

    foreach ($disk in $disks) {
        $totalDisk = [math]::Round($disk.Size / 1GB, 2)
        $freeDisk = [math]::Round($disk.FreeSpace / 1GB, 2)
        $usedDisk = [math]::Round($totalDisk - $freeDisk, 2)
        $usageDisk = [math]::Round(($usedDisk / $totalDisk) * 100, 2)

        Write-Host ""
        Write-Host "  Disque $($disk.DeviceID)" -ForegroundColor White

        Write-Info "Capacite totale" "$totalDisk Go"
        Write-Info "Espace utilise" "$usedDisk Go"
        Write-Info "Espace disponible" "$freeDisk Go"

        $diskColor = if ($usageDisk -ge 90) { "Red" } elseif ($usageDisk -ge 75) { "Yellow" } else { "Green" }

        Write-Host ("  Utilisation : {0} %" -f $usageDisk) -ForegroundColor $diskColor
    }
}
catch {
    Write-Host "  Erreur lors de la recuperation des informations des disques." -ForegroundColor Red
}

# ==========================================
# FIN DU RAPPORT
# ==========================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "              FIN DU RAPPORT SYSTEME" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor DarkCyan
