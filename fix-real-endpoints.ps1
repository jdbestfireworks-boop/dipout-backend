# ============================================
# DipOut Backend: Replace Placeholder Endpoints
# ============================================

Write-Host "Killing Node processes..."
taskkill /F /IM node.exe 2>$null

$backend = "C:\DipOut\dipout-backend"

Write-Host "Fixing trips route..."
$trips = @'
const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, rider: "John Doe", driver: "Mike", status: "completed" },
      { id: 2, rider: "Sarah", driver: "Alex", status: "pending" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Trips fetch failed" });
  }
});

module.exports = router;
'@

Set-Content -Path "$backend\routes\trips.js" -Value $trips -Encoding ASCII

Write-Host "Fixing drivers route..."
$drivers = @'
const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, name: "Mike", car: "Toyota Camry" },
      { id: 2, name: "Alex", car: "Honda Accord" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Drivers fetch failed" });
  }
});

module.exports = router;
'@

Set-Content -Path "$backend\routes\drivers.js" -Value $drivers -Encoding ASCII

Write-Host "Fixing riders route..."
$riders = @'
const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, name: "John Doe" },
      { id: 2, name: "Sarah" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Riders fetch failed" });
  }
});

module.exports = router;
'@

Set-Content -Path "$backend\routes\riders.js" -Value $riders -Encoding ASCII

Write-Host "Restarting backend..."
Set-Location $backend
npm start