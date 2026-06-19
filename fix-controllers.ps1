# ================================
# FIX ALL CONTROLLERS (NO BOM)
# ================================

Write-Host "Fixing controllers (NO BOM)..." -ForegroundColor Yellow

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# --- USER CONTROLLER ---
$userController = @"
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

module.exports = {
  register: async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.create({
        data: { email, password }
      });

      res.json(user);
    } catch (err) {
      console.error("register error:", err);
      res.status(500).json({ error: "Failed to register user" });
    }
  },

  login: async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user || user.password !== password) {
        return res.status(400).json({ error: "Invalid credentials" });
      }

      res.json(user);
    } catch (err) {
      console.error("login error:", err);
      res.status(500).json({ error: "Failed to login" });
    }
  },

  getUser: async (req, res) => {
    try {
      const id = parseInt(req.params.id);

      const user = await prisma.user.findUnique({
        where: { id }
      });

      res.json(user);
    } catch (err) {
      console.error("getUser error:", err);
      res.status(500).json({ error: "Failed to fetch user" });
    }
  }
};
"@

[System.IO.File]::WriteAllText(".\controllers\userController.js", $userController, $utf8NoBom)


# --- DRIVER CONTROLLER ---
$driverController = @"
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

module.exports = {
  updateLocation: async (req, res) => {
    try {
      const userId = req.user.id;
      const { lat, lng } = req.body;

      if (lat == null || lng == null) {
        return res.status(400).json({ error: "lat and lng required" });
      }

      let driver = await prisma.driver.findUnique({ where: { userId } });

      if (!driver) {
        driver = await prisma.driver.create({
          data: { userId, isOnline: true, lat, lng }
        });
      } else {
        driver = await prisma.driver.update({
          where: { userId },
          data: { lat, lng }
        });
      }

      res.json(driver);
    } catch (err) {
      console.error("updateLocation error:", err);
      res.status(500).json({ error: "Failed to update location" });
    }
  },

  updateStatus: async (req, res) => {
    try {
      const userId = req.user.id;
      const { isOnline } = req.body;

      let driver = await prisma.driver.findUnique({ where: { userId } });

      if (!driver) {
        driver = await prisma.driver.create({
          data: { userId, isOnline: !!isOnline }
        });
      } else {
        driver = await prisma.driver.update({
          where: { userId },
          data: { isOnline: !!isOnline }
        });
      }

      res.json(driver);
    } catch (err) {
      console.error("updateStatus error:", err);
      res.status(500).json({ error: "Failed to update status" });
    }
  },

  getNearbyDrivers: async (req, res) => {
    try {
      const drivers = await prisma.driver.findMany({
        where: { isOnline: true },
        include: { user: true }
      });

      res.json(drivers);
    } catch (err) {
      console.error("getNearbyDrivers error:", err);
      res.status(500).json({ error: "Failed to fetch drivers" });
    }
  }
};
"@

[System.IO.File]::WriteAllText(".\controllers\driverController.js", $driverController, $utf8NoBom)


# --- TRIP CONTROLLER ---
$tripController = @"
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

module.exports = {
  createTrip: async (req, res) => {
    try {
      const { riderId, originLat, originLng, destLat, destLng, price } = req.body;

      const trip = await prisma.trip.create({
        data: { riderId, originLat, originLng, destLat, destLng, price }
      });

      res.json(trip);
    } catch (err) {
      console.error("createTrip error:", err);
      res.status(500).json({ error: "Failed to create trip" });
    }
  },

  assignDriver: async (req, res) => {
    try {
      const { tripId, driverId } = req.body;

      const trip = await prisma.trip.update({
        where: { id: tripId },
        data: { driverId, status: "ACCEPTED" }
      });

      res.json(trip);
    } catch (err) {
      console.error("assignDriver error:", err);
      res.status(500).json({ error: "Failed to assign driver" });
    }
  },

  getTrip: async (req, res) => {
    try {
      const id = parseInt(req.params.id);

      const trip = await prisma.trip.findUnique({
        where: { id }
      });

      res.json(trip);
    } catch (err) {
      console.error("getTrip error:", err);
      res.status(500).json({ error: "Failed to fetch trip" });
    }
  }
};
"@

[System.IO.File]::WriteAllText(".\controllers\tripController.js", $tripController, $utf8NoBom)

Write-Host "Controllers fixed successfully (NO BOM)." -ForegroundColor Cyan
