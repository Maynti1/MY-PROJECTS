param([string]$Dir = "D:\My works pages\USA\_cand", [string]$Out = "sheet.jpg", [int]$Cols = 5, [int]$Cell = 420)

Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -Path $Dir -Filter *.jpg |
  Where-Object { $_.Name -ne $Out -and $_.Name -notlike "probe_*" } |
  Where-Object { $_.Length -gt 60000 } |
  Sort-Object Name

$rows = [Math]::Ceiling($files.Count / $Cols)
$labelH = 34
$w = $Cols * $Cell
$h = $rows * ($Cell + $labelH)

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(24, 24, 26))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White
$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = [System.Drawing.StringAlignment]::Center

$i = 0
foreach ($f in $files) {
  $col = $i % $Cols
  $row = [Math]::Floor($i / $Cols)
  $x = $col * $Cell
  $y = $row * ($Cell + $labelH)
  try {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    $scale = [Math]::Min($Cell / $img.Width, $Cell / $img.Height)
    $dw = [int]($img.Width * $scale)
    $dh = [int]($img.Height * $scale)
    $g.DrawImage($img, $x + [int](($Cell - $dw) / 2), $y + [int](($Cell - $dh) / 2), $dw, $dh)
    $img.Dispose()
  } catch {}
  $rect = [System.Drawing.RectangleF]::new([single]$x, [single]($y + $Cell), [single]$Cell, [single]$labelH)
  $g.DrawString($f.BaseName, $font, $brush, $rect, $fmt)
  $i++
}

$g.Dispose()
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ps = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 78)
$bmp.Save((Join-Path $Dir $Out), $enc, $ps)
Write-Output "sheet: $($bmp.Width)x$($bmp.Height) with $i images"
$bmp.Dispose()
