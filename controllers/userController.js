const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

module.exports = {
  register: async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.create({
        data: { email, password }
      });

      res.json(user);
    } catch (err) {
      console.error("register error:", err);
      res.status(500).json({ error: "Failed to register user" });
    }
  },

  login: async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user || user.password !== password) {
        return res.status(400).json({ error: "Invalid credentials" });
      }

      res.json(user);
    } catch (err) {
      console.error("login error:", err);
      res.status(500).json({ error: "Failed to login" });
    }
  },

  getUser: async (req, res) => {
    try {
      const id = parseInt(req.params.id);

      const user = await prisma.user.findUnique({
        where: { id }
      });

      res.json(user);
    } catch (err) {
      console.error("getUser error:", err);
      res.status(500).json({ error: "Failed to fetch user" });
    }
  }
};