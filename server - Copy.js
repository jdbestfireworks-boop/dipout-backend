const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const pool = require("./db");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// ===============================
// HEALTH CHECK
// ===============================
app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

// ===============================
// SIMPLE MESSAGE
// ===============================
app.get("/api/message", (req, res) => {
  res.json({ message: "DipOut backend is ready for real features" });
});

// ===============================
// CREATE A RIDE
// ===============================
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

    console.log("Incoming ride request:", req.body);

    const sql = `
      INSERT INTO rides 
      (rider_id, driver_id, pickup_location, dropoff_location, fare_amount, status)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const params = [
      rider_id,
      driver_id,
      pickup_location,
      dropoff_location,
      fare_amount,
      status
    ];

    const result = await pool.query(sql, params);

    res.json({ success: true, ride: result.rows[0] });

  } catch (err) {
    console.error("Ride request error:", err.message);
    console.error("Full error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ===============================
// FETCH ALL RIDES
// ===============================
app.get("/api/rides", async (req, res) => {
  try {
    const sql = `
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
    `;

    const result = await pool.query(sql);

    res.json(result.rows);

  } catch (err) {
    console.error("Fetch rides error:", err.message);
    console.error("Full error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ===============================
// START SERVER
// ===============================
const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log("DipOut backend running on port " + PORT);
});//
// === AUTO-GENERATED RIDE STATUS ENDPOINTS ===
//

async function updateRideStatus(req, res, newStatus) {
    try {
        const rideId = req.params.id;
        const result = await pool.query(
            "UPDATE rides SET status = $1 WHERE id = $2 RETURNING *",
            [newStatus, rideId]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Ride not found" });
        }
        res.json({ success: true, ride: result.rows[0] });
    } catch (err) {
        console.error("Status update error:", err);
        res.status(500).json({ error: "Internal server error" });
    }
}

app.post("/api/rides/:id/accept", async (req, res) => {
    updateRideStatus(req, res, "accepted");
});

app.post("/api/rides/:id/start", async (req, res) => {
    updateRideStatus(req, res, "en_route");
});

app.post("/api/rides/:id/pickup", async (req, res) => {
    updateRideStatus(req, res, "arrived_pickup");
});

app.post("/api/rides/:id/begin", async (req, res) => {
    updateRideStatus(req, res, "in_progress");
});

app.post("/api/rides/:id/complete", async (req, res) => {
    updateRideStatus(req, res, "completed");
});

//
// === END AUTO-GENERATED BLOCK ===
//
//
// === AUTO-GENERATED DRIVER LOCATION ENDPOINTS ===
//

app.post("/api/driver/:id/location", async (req, res) => {
    try {
        const driverId = req.params.id;
        const { latitude, longitude } = req.body;

        const result = await pool.query(
            "INSERT INTO driver_locations (driver_id, latitude, longitude) VALUES ($1, $2, $3) RETURNING *",
            [driverId, latitude, longitude]
        );

        res.json({ success: true, location: result.rows[0] });
    } catch (err) {
        console.error("Driver location error:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

app.get("/api/driver/:id/location/latest", async (req, res) => {
    try {
        const driverId = req.params.id;

        const result = await pool.query(
            "SELECT * FROM driver_locations WHERE driver_id = $1 ORDER BY recorded_at DESC LIMIT 1",
            [driverId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "No location found" });
        }

        res.json({ success: true, location: result.rows[0] });
    } catch (err) {
        console.error("Latest location error:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

//
// === END AUTO-GENERATED BLOCK ===
//
//
// === AUTO-GENERATED RIDER TRACKING ENDPOINT ===
//

app.get("/api/rides/:id/live", async (req, res) => {
    try {
        const rideId = req.params.id;

        // Fetch ride
        const rideResult = await pool.query(
            "SELECT * FROM rides WHERE id = $1",
            [rideId]
        );

        if (rideResult.rows.length === 0) {
            return res.status(404).json({ error: "Ride not found" });
        }

        const ride = rideResult.rows[0];

        // Fetch driver
        const driverResult = await pool.query(
            "SELECT * FROM drivers WHERE id = $1",
            [ride.driver_id]
        );

        const driver = driverResult.rows.length > 0 ? driverResult.rows[0] : null;

        // Fetch latest driver location
        const locResult = await pool.query(
            "SELECT * FROM driver_locations WHERE driver_id = $1 ORDER BY recorded_at DESC LIMIT 1",
            [ride.driver_id]
        );

        const latestLocation = locResult.rows.length > 0 ? locResult.rows[0] : null;

        res.json({
            success: true,
            ride: ride,
            driver: driver,
            latest_location: latestLocation
        });

    } catch (err) {
        console.error("Live tracking error:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

//
// === END AUTO-GENERATED BLOCK ===
//
