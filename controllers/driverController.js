import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function updateLocation(req, res) {
  try {
    const userId = req.user.id;
    const { lat, lng } = req.body;

    if (lat == null || lng == null) {
      return res.status(400).json({ error: "lat and lng required" });
    }

    let driver = await prisma.driver.findUnique({ where: { userId } });

    if (!driver) {
      driver = await prisma.driver.create({
        data: {
          userId,
          isOnline: true,
          lat,
          lng,
        },
      });
    } else {
      driver = await prisma.driver.update({
        where: { userId },
        data: { lat, lng },
      });
    }

    res.json(driver);
  } catch (err) {
    console.error("updateLocation error:", err);
    res.status(500).json({ error: "Failed to update location" });
  }
}

export async function updateStatus(req, res) {
  try {
    const userId = req.user.id;
    const { isOnline } = req.body;

    let driver = await prisma.driver.findUnique({ where: { userId } });

    if (!driver) {
      driver = await prisma.driver.create({
        data: {
          userId,
          isOnline: !!isOnline,
        },
      });
    } else {
      driver = await prisma.driver.update({
        where: { userId },
        data: { isOnline: !!isOnline },
      });
    }

    res.json(driver);
  } catch (err) {
    console.error("updateStatus error:", err);
    res.status(500).json({ error: "Failed to update status" });
  }
}

export async function getNearbyDrivers(req, res) {
  try {
    const drivers = await prisma.driver.findMany({
      where: { isOnline: true },
      include: { user: true },
    });

    res.json(drivers);
  } catch (err) {
    console.error("getNearbyDrivers error:", err);
    res.status(500).json({ error: "Failed to fetch drivers" });
  }
}
