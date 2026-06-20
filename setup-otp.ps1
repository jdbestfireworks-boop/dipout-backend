Add-Type -AssemblyName System.Windows.Forms

Write-Host "=== DipOut Backend OTP Setup Script ===" -ForegroundColor Cyan

$backend = "C:\Users\jdbes\Desktop\dipout-backend"
$routesDir = Join-Path $backend "routes"
$controllersDir = Join-Path $backend "controllers"
$envFile = Join-Path $backend ".env"

# Ask for Gmail address
$emailForm = New-Object System.Windows.Forms.Form
$emailForm.Text = "Enter Gmail Address"
$emailForm.Width = 400
$emailForm.Height = 150

$emailLabel = New-Object System.Windows.Forms.Label
$emailLabel.Text = "Gmail Address:"
$emailLabel.Left = 10
$emailLabel.Top = 20
$emailLabel.Width = 350
$emailForm.Controls.Add($emailLabel)

$emailBox = New-Object System.Windows.Forms.TextBox
$emailBox.Left = 10
$emailBox.Top = 50
$emailBox.Width = 350
$emailForm.Controls.Add($emailBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Left = 150
$okButton.Top = 80
$okButton.Add_Click({ $emailForm.Close() })
$emailForm.Controls.Add($okButton)

$emailForm.ShowDialog() | Out-Null
$gmailUser = $emailBox.Text

# Ask for Gmail App Password (secure)
$passForm = New-Object System.Windows.Forms.Form
$passForm.Text = "Enter Gmail App Password"
$passForm.Width = 400
$passForm.Height = 150

$passLabel = New-Object System.Windows.Forms.Label
$passLabel.Text = "Gmail App Password:"
$passLabel.Left = 10
$passLabel.Top = 20
$passLabel.Width = 350
$passForm.Controls.Add($passLabel)

$passBox = New-Object System.Windows.Forms.TextBox
$passBox.Left = 10
$passBox.Top = 50
$passBox.Width = 350
$passBox.UseSystemPasswordChar = $true
$passForm.Controls.Add($passBox)

$okButton2 = New-Object System.Windows.Forms.Button
$okButton2.Text = "OK"
$okButton2.Left = 150
$okButton2.Top = 80
$okButton2.Add_Click({ $passForm.Close() })
$passForm.Controls.Add($okButton2)

$passForm.ShowDialog() | Out-Null
$gmailPass = $passBox.Text

# Ask for JWT secret
$jwtForm = New-Object System.Windows.Forms.Form
$jwtForm.Text = "Enter JWT Secret"
$jwtForm.Width = 400
$jwtForm.Height = 150

$jwtLabel = New-Object System.Windows.Forms.Label
$jwtLabel.Text = "JWT Secret (any long random string):"
$jwtLabel.Left = 10
$jwtLabel.Top = 20
$jwtLabel.Width = 350
$jwtForm.Controls.Add($jwtLabel)

$jwtBox = New-Object System.Windows.Forms.TextBox
$jwtBox.Left = 10
$jwtBox.Top = 50
$jwtBox.Width = 350
$jwtForm.Controls.Add($jwtBox)

$okButton3 = New-Object System.Windows.Forms.Button
$okButton3.Text = "OK"
$okButton3.Left = 150
$okButton3.Top = 80
$okButton3.Add_Click({ $jwtForm.Close() })
$jwtForm.Controls.Add($okButton3)

$jwtForm.ShowDialog() | Out-Null
$jwtSecret = $jwtBox.Text

# Write .env file
@"
GMAIL_USER=$gmailUser
GMAIL_PASS=$gmailPass
JWT_SECRET=$jwtSecret
"@ | Set-Content $envFile -Encoding UTF8

Write-Host ".env created with your secure values." -ForegroundColor Green

# Ensure folders exist
if (-not (Test-Path $routesDir)) { New-Item -ItemType Directory -Path $routesDir | Out-Null }
if (-not (Test-Path $controllersDir)) { New-Item -ItemType Directory -Path $controllersDir | Out-Null }

# Update userRoutes.js
@"
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/:id', userController.getUser);

router.post('/send-otp', userController.sendOtp);
router.post('/verify-otp', userController.verifyOtp);
router.post('/resend-otp', userController.resendOtp);

module.exports = router;
"@ | Set-Content (Join-Path $routesDir "userRoutes.js") -Encoding UTF8

# Create userController.js
@"
<--- FULL CONTROLLER CODE FROM PREVIOUS MESSAGE HERE --->
"@ | Set-Content (Join-Path $controllersDir "userController.js") -Encoding UTF8

Write-Host "=== OTP Backend Setup Complete ===" -ForegroundColor Cyan
