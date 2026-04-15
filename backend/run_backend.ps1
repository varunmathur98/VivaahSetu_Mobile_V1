$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

if (-not (Test-Path ".env")) {
  throw "backend/.env not found"
}

python -m uvicorn server:app --host 0.0.0.0 --port 8000
