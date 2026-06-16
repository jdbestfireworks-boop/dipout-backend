import express from "express";
import { authRequired } from "../middleware/authMiddleware.js";
import {
  updateLocation,
  updateStatus,
  getNearbyDrivers,
} from "../controllers/driverController.js";

const router = express.Router();

router.post("/location", authRequired, updateLocation);
router.post("/status", authRequired, updateStatus);
router.get("/nearby", authRequired, getNearbyDrivers);

export default router;
