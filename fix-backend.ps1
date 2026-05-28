# ================================
# DipOut Backend Auto-Fix Script
# Overwrites server.js with a working version
# ================================

Write-Host "Stopping any running Node processes..."
taskkill /F /IM node.exe 2>$null

Write-Host "Writing corrected server.js..."

@"
const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const pool = require("./db");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

// Simple message
app.get("/api/message", (req, res) => {
  res.json({ message: "DipOut backend is ready for real features" });
});

// Create a ride
app.post("/api/rides/request", async (req, res) => {
  try {
    const { rider_name, pickup, destination } = req.body;

    if (!rider_name || !pickup || !destination) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const result = await pool.query(
      "INSERT INTO rides (rider_name, pickup, destination) VALUES ($1, $2, $3) RETURNING *",
      [rider_name, pickup, destination]
    );

    res.json({ success: true, ride: result.rows[0] });

  } catch (err) {
    console.error("Ride request error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Fetch all rides
app.get("/api/rides", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM rides ORDER BY id DESC");
    res.json(result.rows);
  } catch (err) {
    console.error("Fetch rides error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log("DipOut backend running on port " + PORT);
});
"@ | Set-Content -Encoding UTF8 server.js

Write-Host "Starting backend..."
npm start