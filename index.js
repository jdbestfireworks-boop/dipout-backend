import express from "express";
import cors from "cors";
import authRoutes from "./routes/authRoutes.js";

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);

// Default route
app.get("/", (req, res) => {
  res.send("DipOut Backend is running");
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚗 DipOut backend running on port ${PORT}`);
});
