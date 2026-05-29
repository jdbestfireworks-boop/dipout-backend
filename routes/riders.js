const express = require("express");
const router = express.Router();
const db = require("../db");

// GET all riders
router.get("/", async (req, res) => {
  try {
    const result = await db.query("SELECT * FROM riders ORDER BY id ASC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "Riders fetch failed" });
  }
});

// CREATE rider
router.post("/", async (req, res) => {
  try {
    const { name, phone } = req.body;

    const result = await db.query(
      "INSERT INTO riders (name, phone) VALUES ($1, $2) RETURNING *",
      [name, phone]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: "Rider creation failed" });
  }
});

// UPDATE rider
router.put("/:id", async (req, res) => {
  try {
    const { name, phone } = req.body;
    const { id } = req.params;

    const result = await db.query(
      "UPDATE riders SET name=$1, phone=$2 WHERE id=$3 RETURNING *",
      [name, phone, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: "Rider update failed" });
  }
});

// DELETE rider
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    await db.query("DELETE FROM riders WHERE id=$1", [id]);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: "Rider delete failed" });
  }
});

module.exports = router;