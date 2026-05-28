# ============================================
# test-backend.ps1 (bulletproof version)
# ============================================

$baseUrl = "http://localhost:4000"

Write-Host ""
Write-Host "=== TEST 1: /api/health ==="

try {
    $health = Invoke-RestMethod -Method Get -Uri "$baseUrl/api/health"
    Write-Host "PASS: Health endpoint OK -> $($health.status)"
} catch {
    Write-Host "FAIL: /api/health did not respond"
    exit
}

Write-Host ""
Write-Host "=== TEST 2: Create Ride ==="

$body = @{
    rider_id = 1;
    driver_id = 10;
    pickup_location = "123 Main St";
    dropoff_location = "456 Oak St";
    fare_amount = 12.50;
    status = "requested";
}

$json = $body | ConvertTo-Json

try {
    $rideResponse = Invoke-RestMethod -Method Post -Uri "$baseUrl/api/rides/request" -ContentType "application/json" -Body $json
    Write-Host "PASS: Ride created"
    Write-Host "Ride ID: $($rideResponse.ride.id)"
} catch {
    Write-Host "FAIL: Could not create ride"
    Write-Host $_.Exception.Message
    exit
}

Write-Host ""
Write-Host "=== TEST 3: Fetch All Rides ==="

try {
    $rides = Invoke-RestMethod -Method Get -Uri "$baseUrl/api/rides"
    Write-Host "PASS: Rides fetched"
    Write-Host "Total rides returned: $($rides.Count)"
} catch {
    Write-Host "FAIL: Could not fetch rides"
    Write-Host $_.Exception.Message
    exit
}

Write-Host ""
Write-Host "=== ALL TESTS COMPLETE ==="