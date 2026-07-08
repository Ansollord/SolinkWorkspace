$ErrorActionPreference = "Stop"

Set-Location -LiteralPath $PSScriptRoot

$stateDir = Join-Path $env:APPDATA "SolinkWorkspace"
$logFile = Join-Path $stateDir "publish-log.txt"
if (-not (Test-Path -LiteralPath $stateDir)) {
  New-Item -ItemType Directory -Path $stateDir | Out-Null
}

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & git @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
  }
}

function Invoke-Push {
  try {
    Invoke-Git -Arguments @("push", "origin", "main")
    return
  } catch {
    Write-Host ""
    Write-Host "First push failed. Trying to update local branch from GitHub..."
    Invoke-Git -Arguments @("pull", "--rebase", "origin", "main")
    Invoke-Git -Arguments @("push", "origin", "main")
    return
  }
}

function Invoke-SetupGitHubCredentials {
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "Trying to connect Git to GitHub CLI credentials..."
    & gh auth setup-git
  }
}

Start-Transcript -LiteralPath $logFile -Force | Out-Null

Write-Host ""
Write-Host "Solink Workspace publisher"
Write-Host "Repository: $PSScriptRoot"
Write-Host "Log: $logFile"
Write-Host ""

Invoke-Git -Arguments @("status", "--short", "--branch")
Write-Host ""

$changedFiles = git status --porcelain -- index.html projects.json
if ($LASTEXITCODE -ne 0) {
  throw "git status --porcelain failed with exit code $LASTEXITCODE"
}

if ($changedFiles) {
  Write-Host "Committing changed workspace files..."
  Invoke-Git -Arguments @("add", "--", "index.html", "projects.json")
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
  Invoke-Git -Arguments @("commit", "-m", "Update Solink Workspace $stamp")
  Write-Host ""
} else {
  Write-Host "No uncommitted changes in index.html or projects.json."
  Write-Host "Trying to push existing local commits..."
  Write-Host ""
}

try {
  try {
    Invoke-Push
  } catch {
    Invoke-SetupGitHubCredentials
    Invoke-Push
  }

  Write-Host ""
  Write-Host "Done. GitHub Pages may need a minute to refresh."
} catch {
  Write-Host ""
  Write-Host "Publish failed:"
  Write-Host $_
  Write-Host ""
  Write-Host "Log saved to: $logFile"
} finally {
  Stop-Transcript | Out-Null
  Read-Host "Press Enter to close"
}
