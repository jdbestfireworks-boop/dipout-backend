const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    res.json([
      { id: 1, name: "Mike", car: "Toyota Camry" },
      { id: 2, name: "Alex", car: "Honda Accord" }
    ]);
  } catch (err) {
    res.status(500).json({ error: "Drivers fetch failed" });
  }
});

module.exports = router;
