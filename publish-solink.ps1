$ErrorActionPreference = "Stop"

Set-Location -LiteralPath $PSScriptRoot

Write-Host ""
Write-Host "Solink Workspace publisher"
Write-Host "Repository: $PSScriptRoot"
Write-Host ""

git status --short --branch
Write-Host ""

$changedFiles = git status --porcelain -- index.html projects.json

if ($changedFiles) {
  Write-Host "Committing changed workspace files..."
  git add -- index.html projects.json
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
  git commit -m "Update Solink Workspace $stamp"
  Write-Host ""
} else {
  Write-Host "No uncommitted changes in index.html or projects.json."
  Write-Host "Trying to push existing local commits..."
  Write-Host ""
}

git push origin main

Write-Host ""
Write-Host "Done. GitHub Pages may need a minute to refresh."
Read-Host "Press Enter to close"
