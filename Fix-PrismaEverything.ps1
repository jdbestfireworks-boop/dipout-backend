Write-Host "Fixing Prisma schema and datasource..."

$schemaPath = "prisma\schema.prisma"

# --- REMOVE BOM SAFELY ---
$bytes = [System.IO.File]::ReadAllBytes($schemaPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "BOM detected — removing..."
    $bytes = $bytes[3..($bytes.Length-1)]
    [System.IO.File]::WriteAllBytes($schemaPath, $bytes)
}

# --- READ CLEANED FILE ---
$schema = Get-Content $schemaPath -Raw

# --- BUILD NEW DATASOURCE BLOCK WITHOUT MULTILINE STRINGS ---
$newDatasource = 'datasource db {' + "`n" +
'  provider = "postgresql"' + "`n" +
'  url      = env("DATABASE_URL")' + "`n" +
'}'

# --- REPLACE DATASOURCE BLOCK ---
$fixedSchema = $schema -replace 'datasource db \{[\s\S]*?\}', $newDatasource

# --- WRITE CLEAN SCHEMA ---
Set-Content -Path $schemaPath -Value $fixedSchema -Encoding UTF8

Write-Host "Datasource block fixed and BOM removed."

# --- REGENERATE PRISMA CLIENT ---
Write-Host "Regenerating Prisma client..."
npx prisma generate

# --- VALIDATE ---
Write-Host "Validating schema..."
npx prisma validate

Write-Host "Done."
