const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, rider: "John Doe", driver: "Mike", status: "completed" },
      { id: 2, rider: "Sarah", driver: "Alex", status: "pending" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Trips fetch failed" });
  }
});

module.exports = router;
