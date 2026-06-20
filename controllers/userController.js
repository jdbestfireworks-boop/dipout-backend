const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "dipout_secret_key";

// Generate JWT
function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email },
    JWT_SECRET,
    { expiresIn: "7d" }
  );
}

// REGISTER
exports.register = async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return res.status(400).json({ message: "Email already exists" });

    const hashed = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: { email, password: hashed, name, phone }
    });

    const token = generateToken(user);

    res.json({ user, token });
  } catch (err) {
    console.error("REGISTER ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// LOGIN
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(400).json({ message: "Invalid email or password" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Invalid email or password" });

    const token = generateToken(user);

    res.json({ user, token });
  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// GET USER BY ID
exports.getUser = async (req, res) => {
  try {
    const id = Number(req.params.id);
    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) return res.status(404).json({ message: "User not found" });

    res.json({ user });
  } catch (err) {
    console.error("GET USER ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// AUTH MIDDLEWARE FOR /me
exports.me = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) return res.status(401).json({ message: "No token provided" });

    const decoded = jwt.verify(token, JWT_SECRET);

    const user = await prisma.user.findUnique({ where: { id: decoded.id } });

    if (!user) return res.status(404).json({ message: "User not found" });

    res.json({ user });
  } catch (err) {
    console.error("ME ERROR:", err);
    res.status(401).json({ message: "Invalid token" });
  }
};

// OTP PLACEHOLDERS (you can fill these later)
exports.sendOtp = async (req, res) => {
  res.json({ message: "OTP sent (placeholder)" });
};

exports.verifyOtp = async (req, res) => {
  res.json({ message: "OTP verified (placeholder)" });
};

exports.resendOtp = async (req, res) => {
  res.json({ message: "OTP resent (placeholder)" });
};
