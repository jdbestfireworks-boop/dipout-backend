# =====================================================================
# DipOut Backend – Hardened Reset Script
# Deterministic, ASCII-only, block-replacement only
# =====================================================================

$serverFile = "server.js"

Write-Host "Resetting backend routes..."

# ---------------------------------------------------------------------
# 1. Load server.js safely
# ---------------------------------------------------------------------
if (!(Test-Path $serverFile)) {
    Write-Host "ERROR: server.js not found."
    exit 1
}

$content = Get-Content $serverFile -Raw

# ---------------------------------------------------------------------
# 2. Define clean, correct route blocks
# ---------------------------------------------------------------------

$cleanPost = @'
app.post("/api/rides/request", async (req, res) => {
  try {
    const {
      rider_id,
      driver_id,
      pickup_location,
      dropoff_location,
      fare_amount,
      status
    } = req.body;

    const result = await pool.query(
      "INSERT INTO rides (rider_id, driver_id, pickup_location, dropoff_location, fare_amount, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
      [
        rider_id,
        driver_id,
        pickup_location,
        dropoff_location,
        fare_amount,
        status
      ]
    );

    res.json({ success: true, ride: result.rows[0] });

  } catch (err) {
    console.error("Ride request error:", err);
    res.status(500).json({ error: "Server error" });
  }
});
'@

$cleanGet = @'
app.get("/api/rides", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, driver_id, rider_id, pickup_location, dropoff_location, fare_amount, status, created_at FROM rides ORDER BY id DESC"
    );

    res.json(result.rows);

  } catch (err) {
    console.error("Fetch rides error:", err);
    res.status(500).json({ error: "Server error" });
  }
});
'@

# ---------------------------------------------------------------------
# 3. Replace ONLY the ride blocks (safely)
# ---------------------------------------------------------------------

# POST route replacement
$content = $content -replace 'app\.post\("/api/rides/request"[\s\S]*?\}\);', $cleanPost

# GET route replacement
$content = $content -replace 'app\.get\("/api/rides"[\s\S]*?\}\);', $cleanGet

# ---------------------------------------------------------------------
# 4. Write back to server.js (ASCII, no corruption)
# ---------------------------------------------------------------------
Set-Content -Path $serverFile -Value $content -Encoding ASCII

Write-Host "Backend routes reset cleanly."