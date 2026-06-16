import express from "express";
import { authRequired } from "../middleware/authMiddleware.js";
import {
  requestTrip,
  acceptTrip,
  completeTrip,
  getActiveTrips,
} from "../controllers/tripController.js";

const router = express.Router();

router.post("/request", authRequired, requestTrip);
router.post("/accept", authRequired, acceptTrip);
router.post("/complete", authRequired, completeTrip);
router.get("/active", authRequired, getActiveTrips);

export default router;
