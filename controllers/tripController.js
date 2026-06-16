import { PrismaClient, TripStatus } from "@prisma/client";
import { distanceInKm } from "../utils/distance.js";
import { calculatePrice } from "../utils/pricing.js";

const prisma = new PrismaClient();

export async function requestTrip(req, res) {
  try {
    const riderId = req.user.id;
    const { originLat, originLng, destLat, destLng } = req.body;

    if (
      originLat == null ||
      originLng == null ||
      destLat == null ||
      destLng == null
    ) {
      return res.status(400).json({ error: "All coordinates required" });
    }

    const distanceKm = distanceInKm(originLat, originLng, destLat, destLng);
    const price = calculatePrice(distanceKm);

    const trip = await prisma.trip.create({
      data: {
        riderId,
        originLat,
        originLng,
        destLat,
        destLng,
        price,
        status: TripStatus.PENDING,
      },
    });

    res.status(201).json(trip);
  } catch (err) {
    console.error("requestTrip error:", err);
    res.status(500).json({ error: "Failed to request trip" });
  }
}

export async function acceptTrip(req, res) {
  try {
    const driverId = req.user.id;
    const { tripId } = req.body;

    if (!tripId) {
      return res.status(400).json({ error: "tripId required" });
    }

    const trip = await prisma.trip.update({
      where: { id: tripId },
      data: {
        driverId,
        status: TripStatus.ACCEPTED,
      },
    });

    res.json(trip);
  } catch (err) {
    console.error("acceptTrip error:", err);
    res.status(500).json({ error: "Failed to accept trip" });
  }
}

export async function completeTrip(req, res) {
  try {
    const { tripId } = req.body;

    if (!tripId) {
      return res.status(400).json({ error: "tripId required" });
    }

    const trip = await prisma.trip.update({
      where: { id: tripId },
      data: {
        status: TripStatus.COMPLETED,
      },
    });

    res.json(trip);
  } catch (err) {
    console.error("completeTrip error:", err);
    res.status(500).json({ error: "Failed to complete trip" });
  }
}

export async function getActiveTrips(req, res) {
  try {
    const userId = req.user.id;

    const trips = await prisma.trip.findMany({
      where: {
        OR: [
          { riderId: userId, status: { in: [TripStatus.PENDING, TripStatus.ACCEPTED] } },
          { driverId: userId, status: { in: [TripStatus.PENDING, TripStatus.ACCEPTED] } },
        ],
      },
    });

    res.json(trips);
  } catch (err) {
    console.error("getActiveTrips error:", err);
    res.status(500).json({ error: "Failed to fetch active trips" });
  }
}
