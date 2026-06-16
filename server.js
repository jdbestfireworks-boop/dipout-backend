// DIPOUT BACKEND â€” SERVER.JS
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { PrismaClient } from "@prisma/client";
import authRoutes from "./routes/auth.js";
import driverRoutes from "./routes/drivers.js";
import tripRoutes from "./routes/trips.js";

dotenv.config();

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ status: "Backend running", port: 5000 });
});

app.use("/auth", authRoutes);
app.use("/drivers", driverRoutes);
app.use("/trips", tripRoutes);

app.use((err, req, res, next) => {
  console.error("SERVER ERROR:", err);
  res.status(500).json({ error: "Internal server error" });
});

async function startServer() {
  try {
    await prisma.();
    console.log("Connected to PostgreSQL via Prisma");
    app.listen(5000, () => {
      console.log("Backend running on port 5000");
    });
  } catch (error) {
    console.error("Failed to connect to database:", error);
    process.exit(1);
  }
}

startServer();
