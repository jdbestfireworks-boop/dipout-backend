const express = require("express");
const router = express.Router();
const db = require("../config/db");   // ⭐ FIXED: use db directly
const driverController = require("../controllers/driverController");

// ⭐ TEST ROUTE — create a driver in the database
router.post("/create-test", async (req, res) => {
  try {
    const result = await db.query(
      `INSERT INTO drivers (name, email, phone, lat, lng, status)
       VALUES ('Test Driver', 'testdriver@example.com', '555-0000', 32.75, -91.90, 'online')
       RETURNING *`
    );

    res.json({
      message: "Test driver created",
      driver: result.rows[0]
    });
  } catch (err) {
    console.error("Create test driver error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ⭐ REAL ROUTES
router.post("/update-location", driverController.updateLocation);
router.post("/update-status", driverController.updateStatus);
router.get("/nearby", driverController.getNearbyDrivers);

module.exports = router;
