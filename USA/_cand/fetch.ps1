param([string]$Query, [string]$Out, [int]$Width = 2600)

$api = "https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=" + [uri]::EscapeDataString("filetype:bitmap $Query") + "&gsrnamespace=6&gsrlimit=25&prop=imageinfo&iiprop=url|size|mime&iiurlwidth=$Width&format=json"

$json = ""
for ($attempt = 1; $attempt -le 4; $attempt++) {
  $json = curl.exe -s --max-time 60 -H "User-Agent: RoamUSA-Demo/1.0 (design prototype)" $api
  if ($json -and $json -match '"query"') { break }
  Start-Sleep -Seconds (3 * $attempt)
}
if (-not $json) { Write-Output "FAIL-QUERY $Query"; exit 1 }

$data = $json | ConvertFrom-Json
if (-not $data.query) { Write-Output "NO-RESULTS $Query"; exit 1 }

$candidates = @()
foreach ($p in $data.query.pages.PSObject.Properties) {
  $page = $p.Value
  $ii = $page.imageinfo
  if (-not $ii) { continue }
  $info = $ii[0]
  if ($info.mime -ne "image/jpeg") { continue }
  if ($info.width -lt 1800) { continue }
  $ratio = $info.height / $info.width
  if ($ratio -lt 0.45 -or $ratio -gt 0.85) { continue }
  $candidates += [pscustomobject]@{
    title = $page.title
    url = $info.thumburl
    w = $info.width
    h = $info.height
    ratio = [math]::Round($ratio, 2)
  }
}

$candidates = $candidates | Sort-Object -Property @{Expression={ [math]::Abs($_.ratio - 0.63) }} | Select-Object -First 12

$i = 0
foreach ($c in $candidates) {
  $i++
  $tmp = Join-Path $PSScriptRoot ("probe_" + $i + ".jpg")
  $code = curl.exe -s -o $tmp -w "%{http_code}" --max-time 90 -H "User-Agent: RoamUSA-Demo/1.0 (design prototype)" $c.url
  $size = 0
  if (Test-Path $tmp) { $size = (Get-Item $tmp).Length }
  if ($code -eq "200" -and $size -gt 120000) {
    Move-Item -Force $tmp (Join-Path $PSScriptRoot $Out)
    Write-Output "OK $Out <- $($c.title) [$($c.w)x$($c.h)]"
    exit 0
  }
  if (Test-Path $tmp) { Remove-Item -Force $tmp }
}
Write-Output "FAIL $Query"
exit 1
