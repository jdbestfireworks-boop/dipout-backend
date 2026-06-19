const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

module.exports = {
  updateLocation: async (req, res) => {
    try {
      const driverId = 1; // TEMP: testing without auth
      const { lat, lng } = req.body;

      if (lat == null || lng == null) {
        return res.status(400).json({ error: "lat and lng required" });
      }

      const driver = await prisma.driver.update({
        where: { id: driverId },
        data: { lat, lng }
      });

      res.json(driver);
    } catch (err) {
      console.error("updateLocation error:", err);
      res.status(500).json({ error: "Failed to update location" });
    }
  },

  updateStatus: async (req, res) => {
    try {
      const driverId = 1; // TEMP: testing without auth
      const { status } = req.body;

      const driver = await prisma.driver.update({
        where: { id: driverId },
        data: { status }
      });

      res.json(driver);
    } catch (err) {
      console.error("updateStatus error:", err);
      res.status(500).json({ error: "Failed to update status" });
    }
  },

  getNearbyDrivers: async (req, res) => {
    try {
      const drivers = await prisma.driver.findMany(); // SIMPLE + SAFE

      res.json(drivers);
    } catch (err) {
      console.error("getNearbyDrivers error:", err);
      res.status(500).json({ error: "Failed to fetch drivers" });
    }
  }
};
