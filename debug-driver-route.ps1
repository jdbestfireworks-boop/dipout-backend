Write-Host "STEP 1 — Checking driverRoutes.js file..."

$routesPath = "C:\Users\jdbes\Desktop\dipout-backend\routes\driverRoutes.js"

if (!(Test-Path $routesPath)) {
    Write-Host "ERROR: routes/driverRoutes.js NOT FOUND." -ForegroundColor Red
    exit
}

Write-Host "FOUND: $routesPath" -ForegroundColor Green

# -----------------------------------------
# STEP 2 — Insert console logs safely
# -----------------------------------------

Write-Host "STEP 2 — Adding console logs..."

$logTop = 'console.log("driverRoutes.js LOADED");'
$logHit = 'console.log("create-test route HIT");'

$fileContent = Get-Content $routesPath

# Add top log if missing
if ($fileContent -notcontains $logTop) {
    $fileContent = $logTop, $fileContent
}

# Add hit log inside route if missing
if ($fileContent -notcontains $logHit) {
    $newContent = @()
    foreach ($line in $fileContent) {
        $newContent += $line
        if ($line -match 'router.post\("/create-test"') {
            $newContent += "  $logHit"
        }
    }
    $fileContent = $newContent
}

$fileContent | Set-Content $routesPath

Write-Host "Console logs added." -ForegroundColor Green

# -----------------------------------------
# STEP 3 — Start backend in a new window
# -----------------------------------------

Write-Host "STEP 3 — Starting backend server..."

$cmd = 'cd C:\Users\jdbes\Desktop\dipout-backend; node server.js'
Start-Process powershell -ArgumentList "-NoExit", "-Command $cmd"

Start-Sleep -Seconds 3

# -----------------------------------------
# STEP 4 — Run curl test
# -----------------------------------------

Write-Host "STEP 4 — Running test route..."

curl.exe -X POST http://localhost:3000/drivers/create-test

Write-Host "`nSTEP 5 — Check the OTHER PowerShell window for logs." -ForegroundColor Yellow
Write-Host "You should see:" -ForegroundColor Yellow
Write-Host "driverRoutes.js LOADED" -ForegroundColor Green
Write-Host "create-test route HIT" -ForegroundColor Green
Write-Host "FULL DATABASE ERROR BELOW" -ForegroundColor Red
Write-Host "END ERROR" -ForegroundColor Red
