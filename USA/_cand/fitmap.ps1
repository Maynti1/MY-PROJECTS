# Fits the Blank_US_Map SVG projection (Albers conic) so route pins land accurately.
# All parsing happens in a flat scope to avoid PowerShell scoping quirks.

$ErrorActionPreference = "Stop"
$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")

$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'

# ---- collect all rings per state, then centroid of the largest ring ----
$stateCentroid = @{}

foreach ($m in $stateRe.Matches($raw)) {
  $abbr  = $m.Groups[1].Value
  $d     = $m.Groups[2].Value

  $rings      = New-Object System.Collections.ArrayList
  $pts        = New-Object System.Collections.Generic.List[double]
  $tokens     = [regex]::Matches($d, '([mlhvzMLHVZ])|(-?\d*\.?\d+)')
  $cmd        = ''
  $nums       = New-Object System.Collections.Generic.List[double]
  $x = 0.0; $y = 0.0

  foreach ($t in $tokens) {
    if ($t.Groups[1].Success) {
      # flush pending numbers under the previous command
      if ($cmd -ne '' -and $nums.Count -gt 0) {
        $n = $nums.ToArray()
        switch ($cmd.ToLower()) {
          'm' {
            for ($k = 0; $k -lt $nums.Count; $k += 2) {
              if ($cmd -eq 'm') { $x = [double]$n[$k]; $y = [double]$n[$k+1] }
              else { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1] }
              $pts.Add([double]$x); $pts.Add([double]$y)
            }
          }
          'l' {
            for ($k = 0; $k -lt $nums.Count; $k += 2) {
              if ($cmd -eq 'l') { $x = [double]$n[$k]; $y = [double]$n[$k+1] }
              else { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1] }
              $pts.Add([double]$x); $pts.Add([double]$y)
            }
          }
          'h' {
            foreach ($v in $n) {
              if ($cmd -eq 'h') { $x = [double]$v } else { $x = $x + [double]$v }
              $pts.Add([double]$x); $pts.Add([double]$y)
            }
          }
          'v' {
            foreach ($v in $n) {
              if ($cmd -eq 'v') { $y = [double]$v } else { $y = $y + [double]$v }
              $pts.Add([double]$x); $pts.Add([double]$y)
            }
          }
        }
        $nums.Clear()
      }
      $newCmd = $t.Groups[1].Value
      # a new moveto starts a new ring
      if ($cmd.ToLower() -eq 'm' -and $newCmd.ToLower() -eq 'm' -and $pts.Count -ge 6) {
        [void]$rings.Add($pts.ToArray())
        $pts = New-Object System.Collections.Generic.List[double]
      }
      $cmd = $newCmd
    } else {
      $nums.Add([double]$t.Groups[2].Value)
    }
  }
  if ($cmd -ne '' -and $nums.Count -gt 0) {
    $n = $nums.ToArray()
    switch ($cmd.ToLower()) {
      'm' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'm') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1] }; $pts.Add([double]$x); $pts.Add([double]$y) } }
      'l' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'l') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1] }; $pts.Add([double]$x); $pts.Add([double]$y) } }
      'h' { foreach ($v in $n) { if ($cmd -eq 'h') { $x = [double]$v } else { $x = $x + [double]$v }; $pts.Add([double]$x); $pts.Add([double]$y) } }
      'v' { foreach ($v in $n) { if ($cmd -eq 'v') { $y = [double]$v } else { $y = $y + [double]$v }; $pts.Add([double]$x); $pts.Add([double]$y) } }
    }
  }
  if ($pts.Count -ge 6) { [void]$rings.Add($pts.ToArray()) }

  # pick largest ring by |shoelace area|
  $bestArea = 0.0; $bestRing = $null
  foreach ($ring in $rings) {
    $cnt = $ring.Count / 2
    $ar = 0.0
    for ($i = 0; $i -lt $cnt; $i++) {
      $j = ($i + 1) % $cnt
      $ar += [double]$ring[2*$i] * [double]$ring[2*$j+1] - [double]$ring[2*$j] * [double]$ring[2*$i+1]
    }
    $ar = [Math]::Abs($ar / 2.0)
    if ($ar -gt $bestArea) { $bestArea = $ar; $bestRing = $ring }
  }

  if ($bestRing -ne $null) {
    $cnt = $bestRing.Count / 2
    $area = 0.0; $cx = 0.0; $cy = 0.0
    for ($i = 0; $i -lt $cnt; $i++) {
      $j = ($i + 1) % $cnt
      $x0 = [double]$bestRing[2*$i];   $y0 = [double]$bestRing[2*$i+1]
      $x1 = [double]$bestRing[2*$j];   $y1 = [double]$bestRing[2*$j+1]
      $cr = $x0 * $y1 - $x1 * $y0
      $area += $cr
      $cx += ($x0 + $x1) * $cr
      $cy += ($y0 + $y1) * $cr
    }
    $area = $area / 2.0
    if ([Math]::Abs($area) -gt 1e-9) {
      $stateCentroid[$abbr] = @([double]($cx / (6.0 * $area)), [double]($cy / (6.0 * $area)))
    }
  }
}

Write-Output "parsed states: $($stateCentroid.Count)"

# ---- Albers conic equal-area ----
$rad = [Math]::PI / 180.0

function Project-Albers {
  param([double]$lon, [double]$lat, [double]$p1, [double]$p2, [double]$lon0)
  $f1 = $p1 * $rad; $f2 = $p2 * $rad; $fl = $lat * $rad; $ll = $lon * $rad
  $n = ([Math]::Sin($f1) + [Math]::Sin($f2)) / 2.0
  $C = [Math]::Pow([Math]::Cos($f1), 2) + 2.0 * $n * [Math]::Sin($f1)
  $rho  = [Math]::Sqrt($C - 2.0 * $n * [Math]::Sin($fl)) / $n
  $rho0 = [Math]::Sqrt($C) / $n
  $theta = $n * ($ll - $lon0 * $rad)
  return @([double]($rho * [Math]::Sin($theta)), [double]($rho0 - $rho * [Math]::Cos($theta)))
}

# reference states with approximate geographic centroids
$ref = @(
  @('wy', -107.6, 43.0), @('co', -105.6, 39.0), @('nd', -100.4, 47.5), @('sd', -100.1, 44.4),
  @('ne', -99.8, 41.9), @('ks', -98.4, 38.5), @('ok', -97.5, 35.6), @('nm', -106.1, 34.3),
  @('az', -111.7, 34.3), @('ut', -111.7, 39.3), @('nv', -116.9, 39.5), @('id', -114.6, 44.2),
  @('mt', -109.6, 46.9), @('or', -120.6, 43.9), @('wa', -120.7, 47.4), @('tx', -99.3, 31.1),
  @('mn', -94.3, 46.3), @('ia', -93.5, 42.1), @('il', -89.2, 40.1), @('wi', -89.7, 44.6),
  @('mo', -92.5, 38.4), @('ky', -85.3, 37.5), @('tn', -86.3, 35.8), @('nc', -79.5, 35.6),
  @('sc', -80.9, 33.9), @('ga', -83.4, 32.6), @('al', -86.8, 32.8), @('ms', -89.7, 32.7),
  @('la', -92.0, 31.0), @('ar', -92.4, 34.9), @('mi', -85.4, 44.3), @('oh', -82.8, 40.3),
  @('va', -78.7, 37.5), @('pa', -77.8, 40.9), @('ny', -75.5, 42.9), @('me', -69.2, 45.3),
  @('vt', -72.7, 44.1), @('nh', -71.6, 43.7), @('ma', -71.8, 42.3), @('ct', -72.7, 41.6),
  @('nj', -74.5, 40.1), @('md', -76.7, 39.0), @('de', -75.5, 39.0), @('wv', -80.6, 38.6)
)

# cache projections for the reference set per parameter combo
$best = $null
foreach ($p1 in @(29.0, 29.5, 30.0, 30.5)) {
  foreach ($p2 in @(45.0, 45.5, 46.0, 46.5)) {
    foreach ($lon0 in @(-96.0, -96.5, -97.0, -95.5, -98.0, -94.0)) {
      $pts = @()
      foreach ($r in $ref) {
        if (-not $stateCentroid.ContainsKey($r[0])) { continue }
        $p = Project-Albers $r[1] $r[2] $p1 $p2 $lon0
        $pts += ,@([double]$p[0], [double]$p[1], [double]$stateCentroid[$r[0]][0], [double]$stateCentroid[$r[0]][1])
      }
      $n = $pts.Count
      if ($n -lt 20) { continue }
      $mpx=0.0; $mpxx=0.0; $mx=0.0; $mpxy=0.0
      foreach ($p in $pts) { $mpx += $p[0]; $mpxx += $p[0]*$p[0]; $mx += $p[2]; $mpxy += $p[0]*$p[2] }
      $den = $n*$mpxx - $mpx*$mpx
      if ([Math]::Abs($den) -lt 1e-9) { continue }
      $sx = ($n*$mpxy - $mpx*$mx) / $den
      $tx = ($mx - $sx*$mpx) / $n
      $mpy=0.0; $mpyy=0.0; $my=0.0; $mpyx=0.0
      foreach ($p in $pts) { $mpy += $p[1]; $mpyy += $p[1]*$p[1]; $my += $p[3]; $mpyx += $p[1]*$p[3] }
      $den2 = $n*$mpyy - $mpy*$mpy
      if ([Math]::Abs($den2) -lt 1e-9) { continue }
      $sy = ($n*$mpyx - $mpy*$my) / $den2
      $ty = ($my - $sy*$mpy) / $n
      $err = 0.0; $maxErr = 0.0
      foreach ($p in $pts) {
        $dx = $sx*$p[0] + $tx - $p[2]
        $dy = $sy*$p[1] + $ty - $p[3]
        $e = [Math]::Sqrt($dx*$dx + $dy*$dy)
        $err += $e
        if ($e -gt $maxErr) { $maxErr = $e }
      }
      $avg = $err / $n
      if ($best -eq $null -or $avg -lt $best[0]) {
        $best = @($avg, $maxErr, $p1, $p2, $lon0, $sx, $sy, $tx, $ty)
      }
    }
  }
}

if ($best -eq $null) { Write-Output "NO FIT"; exit 1 }
$avgErr=$best[0]; $maxErr=$best[1]; $p1=$best[2]; $p2=$best[3]; $lon0=$best[4]
$sx=$best[5]; $sy=$best[6]; $tx=$best[7]; $ty=$best[8]

Write-Output ("FIT avg={0:N2}px max={1:N2}px parallels={2}/{3} lon0={4} sx={5:N6} sy={6:N6} tx={7:N3} ty={8:N3}" -f $avgErr,$maxErr,$p1,$p2,$lon0,$sx,$sy,$tx,$ty)

$dest = @(
  @('yosemite',  -119.5333, 37.7459), @('grandcanyon', -112.1129, 36.1069),
  @('zion',      -112.9481, 37.2982), @('yellowstone', -110.5885, 44.4280),
  @('glacier',   -113.4218, 48.7742), @('rainier',    -121.7603, 46.8523),
  @('craterlake',-122.1090, 42.9446), @('superior',   -90.5824, 46.7867),
  @('niagara',   -79.0377, 43.0896), @('acadia',     -68.2188, 44.4072),
  @('horseshoe', -111.5107, 36.8791), @('monument',   -110.0989, 37.0041),
  @('bryce',     -112.1677, 37.6283), @('antelope',   -111.3743, 36.8619),
  @('joshua',    -116.3131, 34.1347), @('tahoe',      -120.0324, 39.0968),
  @('brooklyn',  -73.9442, 40.6782), @('chicago',    -87.6298, 41.8781),
  @('neworleans',-90.0715, 29.9511), @('miami',      -80.1918, 25.7617),
  @('seattle',   -122.3321, 47.6062), @('sf',         -122.4194, 37.7749),
  @('denver',    -104.9903, 39.7392), @('boston',     -71.0589, 42.3601),
  @('portland',  -122.6765, 45.5231), @('delaware',   -75.0500, 39.7000)
)

$lines = @()
foreach ($d in $dest) {
  $p = Project-Albers $d[1] $d[2] $p1 $p2 $lon0
  $px = $sx * $p[0] + $tx
  $py = $sy * $p[1] + $ty
  $lines += ("    {0}: {{ x: {1:N2}, y: {2:N2} }}," -f $d[0], $px, $py)
  Write-Output ("{0,-12} -> svg=({1,7:N1},{2,6:N1})  pct=({3,6:N2}%,{4,6:N2}%)" -f $d[0],$px,$py,($px/959*100),($py/593*100))
}

$out = @"
  // Coordinates derived by fitting the Blank_US_Map Albers projection
  // (avg residual $([Math]::Round($avgErr,2)) px over 45 reference states).
  const PINS = {
$($lines -join "`n")
  };
"@
[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\pins.js", $out)
Write-Output "pins.js written"
