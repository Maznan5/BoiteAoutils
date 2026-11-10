<#
.SYNOPSIS
    Contrôle l'état d'une liste de services Windows et produit un compte rendu.

.DESCRIPTION
    Ce script vérifie l'état (Running/Stopped/Introuvable) d'une liste de services
    définie dans le script ou passée en paramètre, affiche un résumé dans la console
    et génère un rapport (TXT, CSV et/ou HTML) horodaté.

.PARAMETER Services
    Liste des noms de services à contrôler (nom court, ex: "Spooler", "wuauserv").
    Si non fourni, utilise la liste par défaut définie dans le script.

.PARAMETER OutputPath
    Dossier où enregistrer les rapports générés. Par défaut : dossier courant.

.PARAMETER Format
    Format(s) de rapport à générer : TXT, CSV, HTML ou All. Par défaut : All.

.PARAMETER ComputerName
    Nom de la machine à contrôler (local par défaut). Permet un contrôle distant.

.EXAMPLE
    .\Check-ServicesStatus.ps1

.EXAMPLE
    .\Check-ServicesStatus.ps1 -Services "Spooler","wuauserv","BITS" -Format HTML

.EXAMPLE
    .\Check-ServicesStatus.ps1 -ComputerName "SERVEUR01" -OutputPath "C:\Rapports"
#>

[CmdletBinding()]
param(
    [string[]]$Services = @(
        "Spooler",      # Spouleur d'impression
        "wuauserv",     # Windows Update
        "BITS",         # Service de transfert intelligent en arrière-plan
        "Dnscache",     # Client DNS
        "W32Time",      # Service d'horloge Windows
        "EventLog",     # Journal des événements Windows
        "WinDefend",    # Microsoft Defender Antivirus
        "LanmanServer", # Serveur (partage de fichiers/imprimantes)
        "Dhcp"          # Client DHCP
    ),

    [string]$OutputPath = (Get-Location).Path,

    [ValidateSet("TXT", "CSV", "HTML", "All")]
    [string]$Format = "All",

    [string]$ComputerName = $env:COMPUTERNAME
)

# ------------------------------------------------------------------
# Préparation
# ------------------------------------------------------------------

$timestamp   = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportBase  = Join-Path -Path $OutputPath -ChildPath "Rapport_Services_$timestamp"
$results     = @()

Write-Host "=== Contrôle des services sur '$ComputerName' ===" -ForegroundColor Cyan
Write-Host "Date : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`n"

# ------------------------------------------------------------------
# Contrôle de chaque service
# ------------------------------------------------------------------

foreach ($svcName in $Services) {

    try {
        $svc = Get-Service -Name $svcName -ComputerName $ComputerName -ErrorAction Stop

        $status = $svc.Status.ToString()
        $startType = $svc.StartType.ToString()

        switch ($status) {
            "Running" { $color = "Green" }
            "Stopped" { $color = "Red" }
            default   { $color = "Yellow" }
        }

        Write-Host ("{0,-20} : {1,-10} (Démarrage : {2})" -f $svcName, $status, $startType) -ForegroundColor $color

        $results += [PSCustomObject]@{
            Horodatage   = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Machine      = $ComputerName
            Service      = $svcName
            NomAffiche   = $svc.DisplayName
            Statut       = $status
            TypeDemarrage= $startType
            Erreur       = ""
        }
    }
    catch {
        Write-Host ("{0,-20} : INTROUVABLE" -f $svcName) -ForegroundColor DarkYellow

        $results += [PSCustomObject]@{
            Horodatage   = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Machine      = $ComputerName
            Service      = $svcName
            NomAffiche   = "N/A"
            Statut       = "INTROUVABLE"
            TypeDemarrage= "N/A"
            Erreur       = $_.Exception.Message
        }
    }
}

# ------------------------------------------------------------------
# Résumé console
# ------------------------------------------------------------------

$nbTotal      = $results.Count
$nbRunning    = ($results | Where-Object { $_.Statut -eq "Running" }).Count
$nbStopped    = ($results | Where-Object { $_.Statut -eq "Stopped" }).Count
$nbIntrouvable= ($results | Where-Object { $_.Statut -eq "INTROUVABLE" }).Count

Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
Write-Host "Total contrôlé   : $nbTotal"
Write-Host "En cours (OK)    : $nbRunning" -ForegroundColor Green
Write-Host "Arrêtés          : $nbStopped" -ForegroundColor Red
Write-Host "Introuvables     : $nbIntrouvable" -ForegroundColor DarkYellow

# ------------------------------------------------------------------
# Génération des rapports
# ------------------------------------------------------------------

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- TXT ---
if ($Format -eq "TXT" -or $Format -eq "All") {
    $txtPath = "$reportBase.txt"
    $lines = @()
    $lines += "=== Rapport de contrôle des services ==="
    $lines += "Machine : $ComputerName"
    $lines += "Date    : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
    $lines += ""
    foreach ($r in $results) {
        $lines += "{0,-20} : {1,-14} (Nom: {2} | Démarrage: {3})" -f $r.Service, $r.Statut, $r.NomAffiche, $r.TypeDemarrage
    }
    $lines += ""
    $lines += "Résumé : $nbRunning OK / $nbStopped arrêté(s) / $nbIntrouvable introuvable(s) sur $nbTotal"
    $lines | Out-File -FilePath $txtPath -Encoding UTF8
    Write-Host "`nRapport TXT  : $txtPath" -ForegroundColor Cyan
}

# --- CSV ---
if ($Format -eq "CSV" -or $Format -eq "All") {
    $csvPath = "$reportBase.csv"
    $results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Rapport CSV  : $csvPath" -ForegroundColor Cyan
}

# --- HTML ---
if ($Format -eq "HTML" -or $Format -eq "All") {
    $htmlPath = "$reportBase.html"

    $rowsHtml = foreach ($r in $results) {
        $rowColor = switch ($r.Statut) {
            "Running"      { "#d4edda" }
            "Stopped"      { "#f8d7da" }
            "INTROUVABLE"  { "#fff3cd" }
            default        { "#ffffff" }
        }
        "<tr style='background-color:$rowColor'><td>$($r.Service)</td><td>$($r.NomAffiche)</td><td>$($r.Statut)</td><td>$($r.TypeDemarrage)</td></tr>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Rapport de contrôle des services</title>
<style>
    body { font-family: Segoe UI, Arial, sans-serif; margin: 30px; color: #222; }
    h1 { color: #0b5394; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ccc; padding: 8px 12px; text-align: left; }
    th { background-color: #0b5394; color: white; }
    .summary { margin-top: 20px; font-weight: bold; }
</style>
</head>
<body>
    <h1>Rapport de contrôle des services</h1>
    <p><strong>Machine :</strong> $ComputerName<br>
       <strong>Date :</strong> $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
    <table>
        <tr><th>Service</th><th>Nom affiché</th><th>Statut</th><th>Type de démarrage</th></tr>
        $($rowsHtml -join "`n")
    </table>
    <p class="summary">Résumé : $nbRunning OK / $nbStopped arrêté(s) / $nbIntrouvable introuvable(s) sur $nbTotal</p>
</body>
</html>s
"@

    $html | Out-File -FilePath $htmlPath -Encoding UTF8
    Write-Host "Rapport HTML : $htmlPath" -ForegroundColor Cyan
}

Write-Host "`nContrôle terminé.`n" -ForegroundColor Cyan