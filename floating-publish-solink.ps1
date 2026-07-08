$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$repoDir = $PSScriptRoot
$publisher = Join-Path $repoDir "publish-solink.cmd"
$stateDir = Join-Path $env:APPDATA "SolinkWorkspace"
$stateFile = Join-Path $stateDir "floating-publish-position.json"

if (-not (Test-Path -LiteralPath $stateDir)) {
  New-Item -ItemType Directory -Path $stateDir | Out-Null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Publish Solink"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.TopMost = $true
$form.ShowInTaskbar = $true
$form.Width = 148
$form.Height = 44
$form.BackColor = [System.Drawing.Color]::FromArgb(17, 119, 103)
$form.Opacity = 0.94

$saved = $null
if (Test-Path -LiteralPath $stateFile) {
  try {
    $saved = Get-Content -Raw -LiteralPath $stateFile | ConvertFrom-Json
  } catch {
    $saved = $null
  }
}

if ($saved -and $saved.x -ne $null -and $saved.y -ne $null) {
  $form.Location = New-Object System.Drawing.Point([int]$saved.x, [int]$saved.y)
} else {
  $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
  $form.Location = New-Object System.Drawing.Point(($screen.Right - $form.Width - 24), ($screen.Bottom - $form.Height - 24))
}

$button = New-Object System.Windows.Forms.Button
$button.Text = "Publish"
$button.Dock = [System.Windows.Forms.DockStyle]::Fill
$button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button.FlatAppearance.BorderSize = 0
$button.BackColor = [System.Drawing.Color]::FromArgb(17, 119, 103)
$button.ForeColor = [System.Drawing.Color]::White
$button.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$button.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($button)

$dragging = $false
$dragStart = New-Object System.Drawing.Point(0, 0)
$formStart = New-Object System.Drawing.Point(0, 0)
$dragMoved = $false

$mouseDown = {
  param($sender, $event)
  if ($event.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
    $form.Close()
    return
  }
  if ($event.Button -ne [System.Windows.Forms.MouseButtons]::Left) { return }
  $script:dragging = $true
  $script:dragMoved = $false
  $script:dragStart = [System.Windows.Forms.Cursor]::Position
  $script:formStart = $form.Location
}

$mouseMove = {
  param($sender, $event)
  if (-not $script:dragging) { return }
  $current = [System.Windows.Forms.Cursor]::Position
  $dx = $current.X - $script:dragStart.X
  $dy = $current.Y - $script:dragStart.Y
  if ([Math]::Abs($dx) -gt 3 -or [Math]::Abs($dy) -gt 3) {
    $script:dragMoved = $true
  }
  $form.Location = New-Object System.Drawing.Point(($script:formStart.X + $dx), ($script:formStart.Y + $dy))
}

$mouseUp = {
  param($sender, $event)
  if (-not $script:dragging) { return }
  $script:dragging = $false
  @{ x = $form.Location.X; y = $form.Location.Y } |
    ConvertTo-Json |
    Set-Content -LiteralPath $stateFile -Encoding UTF8
}

$publish = {
  if ($script:dragMoved) {
    $script:dragMoved = $false
    return
  }
  $button.Enabled = $false
  $button.Text = "Pushing..."
  try {
    Start-Process -FilePath $publisher -WorkingDirectory $repoDir
  } finally {
    $button.Text = "Publish"
    $button.Enabled = $true
  }
}

$form.Add_MouseDown($mouseDown)
$form.Add_MouseMove($mouseMove)
$form.Add_MouseUp($mouseUp)
$button.Add_MouseDown($mouseDown)
$button.Add_MouseMove($mouseMove)
$button.Add_MouseUp($mouseUp)
$button.Add_Click($publish)

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
