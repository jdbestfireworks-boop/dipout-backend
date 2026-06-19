# ================================
# CLEAN PRISMA FOLDER + CREATE NO-BOM SCHEMA
# ================================

Write-Host "Removing old prisma folder (if exists)..." -ForegroundColor Yellow
if (Test-Path ".\prisma") {
    Remove-Item -Recurse -Force ".\prisma"
}

Write-Host "Creating new prisma folder..." -ForegroundColor Green
New-Item -ItemType Directory "prisma" | Out-Null

Write-Host "Creating clean schema.prisma (NO BOM)..." -ForegroundColor Green
$schemaPath = ".\prisma\schema.prisma"

# Create empty UTF-8 (NO BOM) file
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($schemaPath, "", $utf8NoBom)

Write-Host "Writing schema content..." -ForegroundColor Green

$schemaContent = @"
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            Int            @id @default(autoincrement())
  email         String         @unique
  password      String
  role          UserRole       @default(RIDER)
  createdAt     DateTime       @default(now())
  updatedAt     DateTime       @updatedAt
  driver        Driver?
  tripsAsRider  Trip[]         @relation("RiderTrips")
  refreshTokens RefreshToken[]
}

model Driver {
  id        Int      @id @default(autoincrement())
  userId    Int      @unique
  user      User     @relation(fields: [userId], references: [id])
  isOnline  Boolean  @default(false)
  lat       Float?
  lng       Float?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  trips     Trip[]
}

model Trip {
  id         Int         @id @default(autoincrement())
  riderId    Int
  driverId   Int?
  rider      User        @relation("RiderTrips", fields: [riderId], references: [id])
  driver     Driver?     @relation(fields: [driverId], references: [id])
  status     TripStatus  @default(PENDING)
  originLat  Float
  originLng  Float
  destLat    Float
  destLng    Float
  price      Float
  createdAt  DateTime    @default(now())
}

model RefreshToken {
  id        Int      @id @default(autoincrement())
  token     String   @unique
  userId    Int
  user      User     @relation(fields: [userId], references: [id])
  expiresAt DateTime
  createdAt DateTime @default(now())
}

enum TripStatus {
  PENDING
  ACCEPTED
  COMPLETED
  CANCELED
}

enum UserRole {
  RIDER
  DRIVER
  ADMIN
}
"@

# Write schema with NO BOM
[System.IO.File]::WriteAllText($schemaPath, $schemaContent, $utf8NoBom)

Write-Host "Schema created successfully with NO BOM." -ForegroundColor Cyan
Write-Host "Run: npx prisma generate" -ForegroundColor Magenta
