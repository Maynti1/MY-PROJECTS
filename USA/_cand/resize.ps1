param([string]$Src, [string]$Out, [int]$Width = 2000, [int]$Quality = 82)

Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile($Src)
$ratio = $img.Width / $img.Height

if ($Width -gt 0 -and $img.Width -gt $Width) {
  $w = $Width
  $h = [int][Math]::Round($Width / $ratio)
} else {
  $w = $img.Width
  $h = $img.Height
}

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.DrawImage($img, 0, 0, $w, $h)
$g.Dispose()
$img.Dispose()

$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ps = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)
$bmp.Save($Out, $enc, $ps)
$bmp.Dispose()

Write-Output ("{0}  {1}x{2}  {3} KB" -f (Split-Path $Out -Leaf), $w, $h, [int]((Get-Item $Out).Length / 1KB))
