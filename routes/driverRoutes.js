const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const driverController = require("../controllers/driverController");

console.log("driverRoutes.js LOADED");

// ⭐ TEST ROUTE — create a driver using Prisma
router.post("/create-test", async (req, res) => {
  console.log("create-test route HIT");
  try {
    const driver = await prisma.driver.create({
      data: {
        name: "Test Driver",
        email: "testdriver@example.com",
        phone: "555-0000",
        lat: 32.75,
        lng: -91.90,
        status: "online"
      }
    });

    res.json({
      message: "Test driver created",
      driver
    });
  } catch (err) {
    console.error("FULL DATABASE ERROR BELOW");
    console.error(err);
    console.error("END ERROR");
    res.status(500).json({ message: "Server error" });
  }
});

// ⭐ REAL ROUTES
router.post("/update-location", driverController.updateLocation);
router.post("/update-status", driverController.updateStatus);
router.get("/nearby", driverController.getNearbyDrivers);

module.exports = router;
