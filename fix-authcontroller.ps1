Write-Host "Fixing authController.js..." -ForegroundColor Cyan

@"
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

// Temporary in-memory user store
const users = [];
const otps = new Map();

const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-key";
const OTP_EXPIRY_MINUTES = 10;

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function createToken(user) {
  return jwt.sign(
    { email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: "7d" }
  );
}

// POST /register
export const register = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const existing = users.find(u => u.email === email);
    if (existing) {
      return res.status(400).json({ message: "User already exists" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = {
      email,
      passwordHash,
      role: role || "rider",
      isVerified: false,
    };
    users.push(user);

    const code = generateOtp();
    const expiresAt = Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000;
    otps.set(email, { code, expiresAt });

    console.log(\`OTP for \${email}: \${code}\`);

    return res.status(200).json({ message: "User registered. OTP sent." });
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /verify-otp
export const verifyOtp = (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: "Email and OTP are required" });
    }

    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    const record = otps.get(email);
    if (!record) {
      return res.status(400).json({ message: "No OTP found. Please request a new code." });
    }

    if (Date.now() > record.expiresAt) {
      otps.delete(email);
      return res.status(400).json({ message: "OTP expired. Please request a new code." });
    }

    if (record.code !== otp) {
      return res.status(400).json({ message: "Invalid code. Please try again." });
    }

    user.isVerified = true;
    otps.delete(email);

    const token = createToken(user);

    return res.status(200).json({ message: "OTP verified", token });
  } catch (err) {
    console.error("Verify OTP error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /resend-otp
export const resendOtp = (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    const code = generateOtp();
    const expiresAt = Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000;
    otps.set(email, { code, expiresAt });

    console.log(\`Resent OTP for \${email}: \${code}\`);

    return res.status(200).json({ message: "OTP resent" });
  } catch (err) {
    console.error("Resend OTP error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /login
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    if (!user.isVerified) {
      return res.status(400).json({ message: "Please verify your email before logging in" });
    }

    const token = createToken(user);

    return res.status(200).json({ message: "Logged in", token });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
"@ | Set-Content "./controllers/authController.js"

Write-Host "authController.js fixed successfully!" -ForegroundColor Green
