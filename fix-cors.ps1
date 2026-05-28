# Auto-detect and fix CORS in server.js (safe + idempotent)

$path = "C:\DipOut\dipout-backend\server.js"
$backup = "C:\DipOut\dipout-backend\server.js.bak"

# Backup original file
Copy-Item $path $backup -Force

# Read file
$content = Get-Content $path -Raw

# If CORS already exists, exit
if ($content -match "app.use\(cors") {
    Write-Host "CORS already present. No changes made."
    exit
}

# Detect module type
$usesImport = $content -match "import express"
$usesRequire = $content -match "require\(['""]express['""]\)"

# Build CORS blocks
$corsBlockImport = @"
import cors from "cors";

app.use(cors({
  origin: "*",
  methods: ["GET","POST","PUT","DELETE","OPTIONS"],
  allowedHeaders: ["Content-Type","Authorization"]
}));
"@

$corsBlockRequire = @"
const cors = require("cors");

app.use(cors({
  origin: "*",
  methods: ["GET","POST","PUT","DELETE","OPTIONS"],
  allowedHeaders: ["Content-Type","Authorization"]
}));
"@

# Insert CORS block after express initialization
if ($usesImport) {
    $content = $content -replace "(import express[^\n]*\n)", "`$1$corsBlockImport`n"
}
elseif ($usesRequire) {
    $content = $content -replace "(const express[^\n]*\n)", "`$1$corsBlockRequire`n"
}
else {
    Write-Host "Could not detect express import/require. No changes made."
    exit
}

# Write updated file
Set-Content -Path $path -Value $content -Encoding ASCII

Write-Host "CORS successfully injected into server.js"