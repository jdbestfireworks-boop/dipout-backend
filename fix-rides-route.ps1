# ================================
# DipOut Backend Rides Route Fix
# Overwrites ONLY the GET /api/rides route
# ================================

Write-Host "Stopping Node..."
taskkill /F /IM node.exe 2>$null

Write-Host "Patching server.js rides route..."

# Read the entire server.js
$server = Get-Content server.js -Raw

# Remove any existing GET /api/rides route
$server = $server -replace 'app.get\("/api/rides"[\s\S]*?}\);', ''

# Append the corrected GET route at the end
$fixedRoute = @"
app.get("/api/rides", async (req, res) => {
  try {
    const result = await pool.query(\`
      SELECT 
        id,
        driver_id,
        rider_id,
        pickup_location,
        dropoff_location,
        fare_amount,
        status,
        created_at
      FROM rides
      ORDER BY id DESC
    \`);

    res.json(result.rows);
  } catch (err) {
    console.error("Fetch rides error:", err);
    res.status(500).json({ error: "Server error" });
  }
});
"@

$server = $server + "`r`n" + $fixedRoute

# Write back to server.js
$server | Set-Content -Encoding UTF8 server.js

Write-Host "Restarting backend..."
npm start