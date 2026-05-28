$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot\.."
try {
  npm install
  npm run build:windows
} finally {
  Pop-Location
}
