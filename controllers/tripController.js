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