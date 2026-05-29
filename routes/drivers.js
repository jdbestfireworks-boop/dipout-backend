const express = require("express");
const router = express.Router();
const db = require("../db");

// GET all drivers
router.get("/", async (req, res) => {
  try {
    const result = await db.query("SELECT * FROM drivers ORDER BY id ASC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "Drivers fetch failed" });
  }
});

// CREATE driver
router.post("/", async (req, res) => {
  try {
    const { name, car, phone } = req.body;

    const result = await db.query(
      "INSERT INTO drivers (name, car, phone) VALUES ($1, $2, $3) RETURNING *",
      [name, car, phone]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: "Driver creation failed" });
  }
});

// UPDATE driver
router.put("/:id", async (req, res) => {
  try {
    const { name, car, phone } = req.body;
    const { id } = req.params;

    const result = await db.query(
      "UPDATE drivers SET name=$1, car=$2, phone=$3 WHERE id=$4 RETURNING *",
      [name, car, phone, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: "Driver update failed" });
  }
});

// DELETE driver
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    await db.query("DELETE FROM drivers WHERE id=$1", [id]);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: "Driver delete failed" });
  }
});

module.exports = router;