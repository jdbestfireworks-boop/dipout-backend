$envPath = "C:\Users\jdbes\Desktop\dipout-backend\.env"

# Delete old .env if it exists
if (Test-Path $envPath) {
    Remove-Item $envPath -Force
}

# Correct connection string
$dbUrl = 'DATABASE_URL="postgresql://dipout_db_user:I97YA9NbBc4mCGB72lQQMp6i6QEbE4Bi@dpg-d8nc8i3bc2fs73esl2bg-a.oregon-postgres.render.com:5432/dipout_db?sslmode=require&pgbouncer=true&connect_timeout=10"'

# Create new .env
Set-Content -Path $envPath -Value $dbUrl -Encoding UTF8

# Show the file contents so you can confirm
Write-Host "`nNEW .env CONTENTS:"
Get-Content $envPath

# Kill Node
taskkill /F /IM node.exe 2>$null

# Restart backend
cd "C:\Users\jdbes\Desktop\dipout-backend"
node server.js
