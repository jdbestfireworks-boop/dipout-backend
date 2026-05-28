const { Pool } = require("pg");

const pool = new Pool({
  connectionString: "postgresql://dipout_user:gr24kjfEQ6pt50dM4v3svWn9v9dwn35i@dpg-d8acjvreo5us739ir0mg-a.oregon-postgres.render.com/dipout",
  ssl: { rejectUnauthorized: false }
});

pool.query(
  "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name='rides';"
)
  .then(res => {
    console.log("=== RENDER DB: rides table schema ===");
    console.table(res.rows);
    process.exit(0);
  })
  .catch(err => {
    console.error("Schema check error:", err);
    process.exit(1);
  });