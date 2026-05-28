# ============================================
# fix-env.ps1
# Finds and deletes .env.local anywhere on C:
# Restarts backend and runs test script
# ============================================

Write-Host "`n=== STEP 1: Searching for .env.local on C: ===`n"

$envFiles = Get-ChildItem -Path C:\ -Recurse -Filter ".env.local" -ErrorAction SilentlyContinue

if ($envFiles.Count -eq 0) {
    Write-Host "No .env.local found on C: drive"
} else {
    Write-Host "Found .env.local at:"
    $envFiles | ForEach-Object { Write-Host $_.FullName }

    Write-Host "`n=== STEP 2: Deleting .env.local ===`n"
    $envFiles | ForEach-Object { Remove-Item -Force $_.FullName }
    Write-Host "Deleted all .env.local files"
}

Write-Host "`n=== STEP 3: Killing all Node processes ===`n"
taskkill /F /IM node.exe 2>$null

Write-Host "`n=== STEP 4: Restarting backend ===`n"
Start-Process powershell -ArgumentList "cd C:\DipOut\dipout-backend; npm start"

Start-Sleep -Seconds 3

Write-Host "`n=== STEP 5: Running backend test script ===`n"
powershell -ExecutionPolicy Bypass -File C:\DipOut\dipout-backend\test-backend.ps1

Write-Host "`n=== FIX COMPLETE ===`n"