# Deploy script executed on the Windows server over OpenSSH.
# Piped in via: ssh user@host "powershell -NoProfile -ExecutionPolicy Bypass -Command -" < cd/deploy.ps1

$AppDir = 'C:\inetpub\wwwroot\test-api'
$Pm2App = 'test-api'

$ErrorActionPreference = 'Stop'

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Body
    )
    Write-Host "--- $Name ---"
    & $Body
    if ($LASTEXITCODE -ne 0) { throw "$Name failed (exit $LASTEXITCODE)" }
}

try {
    Write-Host "========== START DEPLOY =========="
    Write-Host "App directory: $AppDir"
    Write-Host "Host:          $env:COMPUTERNAME"

    Set-Location $AppDir

    Invoke-Step 'git fetch'    { git fetch --all --prune }
    Invoke-Step 'git checkout' { git checkout main }
    Invoke-Step 'git reset'    { git reset --hard origin/main }
    git log -1 --oneline

    Invoke-Step 'npm ci'        { npm ci }
    Invoke-Step 'npm run build' { npm run build }

    Write-Host "--- pm2 reload ---"
    pm2 reload $Pm2App
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Reload failed, starting app fresh..."
        pm2 start src/index.js --name $Pm2App
        if ($LASTEXITCODE -ne 0) { throw "pm2 start failed" }
    }
    pm2 save
    pm2 list

    Write-Host "Deployment completed successfully."
    Write-Host "========== END DEPLOY =========="
    exit 0
}
catch {
    Write-Host "DEPLOY FAILED: $_"
    exit 1
}
