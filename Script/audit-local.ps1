# Fonctionnalité B - Audit local
# Liste les comptes utilisateurs locaux et les informations utiles à un contrôle administratif.
# À lancer dans PowerShell en tant qu'administrateur.
 
# Membres du groupe Administrateurs (SID S-1-5-32-544, fonctionne quelle que soit la langue de Windows)
$groupeAdmin = Get-LocalGroup -SID "S-1-5-32-544"
$admins = (Get-LocalGroupMember -Group $groupeAdmin -ErrorAction SilentlyContinue).SID.Value
 
# Récupération des comptes locaux
$comptes = Get-LocalUser | ForEach-Object {
    [PSCustomObject]@{
        Nom               = $_.Name
        Description       = $_.Description
        Actif             = $_.Enabled
        Administrateur    = $admins -contains $_.SID.Value
        DerniereConnexion = $_.LastLogon
        MdpModifieLe      = $_.PasswordLastSet
        MdpExpireLe       = $_.PasswordExpires
        MdpObligatoire    = $_.PasswordRequired
        CompteExpireLe    = $_.AccountExpires
    }
}
 
# Affichage à l'écran
Write-Host "Audit des comptes locaux - $env:COMPUTERNAME - $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Cyan
$comptes | Format-Table -AutoSize
 
# Export CSV (ouvrable dans Excel)
$fichier = Join-Path (Get-Location) "Audit_${env:COMPUTERNAME}_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"
$comptes | Export-Csv -Path $fichier -Delimiter ";" -NoTypeInformation -Encoding UTF8
Write-Host "Rapport enregistré : $fichier" -ForegroundColor Green