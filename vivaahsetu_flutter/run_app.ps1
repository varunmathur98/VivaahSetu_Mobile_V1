$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$flutterBin = "C:\Users\varun\Development\flutter\bin\flutter.bat"
$backendUrl = "https://api.vivaahsetu.in"
$localPubCache = Join-Path (Split-Path -Parent $projectRoot) ".pub-cache"
$packageConfig = Join-Path $projectRoot ".dart_tool\package_config.json"
$androidGradleDir = Join-Path $projectRoot "android\.gradle"
$buildDir = Join-Path $projectRoot "build"
$dartToolDir = Join-Path $projectRoot ".dart_tool"
if (-not (Test-Path $flutterBin)) {
  throw "Flutter binary not found at $flutterBin"
}

New-Item -ItemType Directory -Force -Path $localPubCache | Out-Null
$env:PUB_CACHE = $localPubCache

function Remove-StaleState {
  Write-Host "Repairing Flutter metadata for this repo..." -ForegroundColor Yellow
  Remove-Item -Recurse -Force $dartToolDir -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force $androidGradleDir -ErrorAction SilentlyContinue
  & $flutterBin pub get
}

$needsRepair = $true
if (Test-Path $packageConfig) {
  $configText = Get-Content $packageConfig -Raw
  $needsRepair = $configText -match "file:///V:/" -or $configText -match "your/pub_cache/folder"
}

if ($needsRepair) {
  Remove-StaleState
}

$adbDevices = & adb devices
$deviceLines = $adbDevices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" }
if (-not $deviceLines) {
  throw "No Android device detected. Connect the phone, unlock it, and enable USB debugging."
}

$deviceId = ($deviceLines[0] -split "\s+")[0]
Write-Host "Launching on device $deviceId with PUB_CACHE=$localPubCache and BACKEND_URL=$backendUrl" -ForegroundColor Green

Set-Location $projectRoot
& $flutterBin run -d $deviceId --fast-start --no-pub --dart-define="BACKEND_URL=$backendUrl" --target lib/main.dart
