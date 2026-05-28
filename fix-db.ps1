# ============================
# fix-db.ps1
# Deterministic DB config tool
# ============================

Write-Host ""
Write-Host "Select database mode:"
Write-Host "1 = Render Cloud Database"
Write-Host "2 = Local PostgreSQL"
Write-Host ""

$choice = Read-Host "Enter 1 or 2"

$envPath = "C:\DipOut\dipout-backend\.env"
$dbPath  = "C:\DipOut\dipout-backend\db.js"

# Stop if files don't exist
if (!(Test-Path $envPath)) { Write-Host ".env not found"; exit }
if (!(Test-Path $dbPath))  { Write-Host "db.js not found"; exit }

# ============================
# OPTION 1: RENDER DATABASE
# ============================
if ($choice -eq "1") {

$renderEnv = @"
DATABASE_URL=postgresql://dipout_user:gr24kjfEQ6pt50dM4v3svWn9v9dwn35i@dpg-d8acjvreo5us739ir0mg-a.oregon-postgres.render.com/dipout
"@

$renderDbJs = @"
const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

module.exports = pool;
"@

Set-Content -Path $envPath -Value $renderEnv -Encoding ASCII
Set-Content -Path $dbPath  -Value $renderDbJs -Encoding ASCII

Write-Host ""
Write-Host "Render DB configuration applied."
exit
}

# ============================
# OPTION 2: LOCAL DATABASE
# ============================
if ($choice -eq "2") {

$localEnv = @"
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dipout
"@

$localDbJs = @"
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: false
});

module.exports = pool;
"@

Set-Content -Path $envPath -Value $localEnv -Encoding ASCII
Set-Content -Path $dbPath  -Value $localDbJs -Encoding ASCII

Write-Host ""
Write-Host "Local DB configuration applied."
exit
}

Write-Host "Invalid selection."