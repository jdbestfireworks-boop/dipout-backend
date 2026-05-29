const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, name: "John Doe" },
      { id: 2, name: "Sarah" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Riders fetch failed" });
  }
});

module.exports = router;
