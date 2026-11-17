# Calibrates the Blank_US_Map SVG projection against per-state bounding boxes
# and emits pin coordinates in SVG space (959x593).

$ErrorActionPreference = "Stop"
$inv = [System.Globalization.CultureInfo]::InvariantCulture

# ---- load state boxes ----
$js = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\state-boxes.js")
$boxes = @{}
foreach ($m in [regex]::Matches($js, '([a-z]{2}): \[([-0-9., ]+)\]')) {
  $parts = $m.Groups[2].Value.Split(',')
  $d = @()
  foreach ($p in $parts) { $d += [double]::Parse($p.Trim(), $inv) }
  $boxes[$m.Groups[1].Value] = $d
}
Write-Output "boxes loaded: $($boxes.Count)"

$rad = [Math]::PI / 180.0

function Proj {
  param([double]$lon, [double]$lat, [double]$p1, [double]$p2, [double]$lon0)
  $f1 = $p1*$rad; $f2 = $p2*$rad; $fl = $lat*$rad; $ll = $lon*$rad
  $n = ([Math]::Sin($f1) + [Math]::Sin($f2)) / 2.0
  $C = [Math]::Pow([Math]::Cos($f1),2) + 2.0*$n*[Math]::Sin($f1)
  $rho  = [Math]::Sqrt($C - 2.0*$n*[Math]::Sin($fl)) / $n
  $rho0 = [Math]::Sqrt($C) / $n
  $th = $n * ($ll - $lon0*$rad)
  return @([double]($rho*[Math]::Sin($th)), [double]($rho0 - $rho*[Math]::Cos($th)))
}

# ---- reference states: geographic bbox centre -> SVG bbox centre ----
$refSpec = @"
wy -107.6 43.0
co -105.6 39.0
nd -100.4 47.5
sd -100.1 44.4
ne -99.8 41.9
ks -98.4 38.5
ok -97.5 35.6
nm -106.1 34.3
az -111.7 34.3
ut -111.7 39.3
nv -116.9 39.5
id -114.6 44.2
mt -109.6 46.9
or -120.6 43.9
wa -120.7 47.4
tx -99.3 31.1
mn -94.3 46.3
ia -93.5 42.1
il -89.2 40.1
wi -89.7 44.6
mo -92.5 38.4
ky -85.3 37.5
tn -86.3 35.8
nc -79.5 35.6
sc -80.9 33.9
ga -83.4 32.6
al -86.8 32.8
ms -89.7 32.7
la -92.0 31.0
ar -92.4 34.9
mi -85.4 44.3
oh -82.8 40.3
va -78.7 37.5
pa -77.8 40.9
ny -75.5 42.9
me -69.2 45.3
vt -72.7 44.1
nh -71.6 43.7
ma -71.8 42.3
ct -72.7 41.6
nj -74.5 40.1
md -76.7 39.0
de -75.5 39.0
wv -80.6 38.6
ca -119.4 37.2
"@

$ref = New-Object System.Collections.ArrayList
foreach ($line in ($refSpec -split "`n")) {
  $t = $line.Trim()
  if (-not $t) { continue }
  $w = $t -split '\s+'
  if (-not $boxes.ContainsKey($w[0])) { continue }
  $b = $boxes[$w[0]]
  [void]$ref.Add([pscustomobject]@{
    st = $w[0]
    lon = [double]::Parse($w[1], $inv)
    lat = [double]::Parse($w[2], $inv)
    sx = ($b[0] + $b[2]) / 2.0
    sy = ($b[1] + $b[3]) / 2.0
  })
}
Write-Output "reference points: $($ref.Count)"

$best = $null
foreach ($p1 in 28.0..31.0) {
  foreach ($p2 in 43.5..47.5) {
    foreach ($lon0 in -100.0..-93.0) {
      # flat array: px, py, sx, sy per reference point (stride 4)
      $flat = New-Object System.Collections.Generic.List[double]
      foreach ($r in $ref) {
        $q = Proj $r.lon $r.lat $p1 $p2 $lon0
        $flat.Add([double]$q[0]); $flat.Add([double]$q[1])
        $flat.Add([double]$r.sx);     $flat.Add([double]$r.sy)
      }
      $n = $ref.Count
      $mpx=0.0;$mpxx=0.0;$mx=0.0;$mpxy=0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) {
        $mpx += $flat[$k]; $mpxx += $flat[$k]*$flat[$k]
        $mx  += $flat[$k+2]; $mpxy += $flat[$k]*$flat[$k+2]
      }
      $den = $n*$mpxx - $mpx*$mpx
      if ([Math]::Abs($den) -lt 1e-9) { continue }
      $A = ($n*$mpxy - $mpx*$mx)/$den
      $B = ($mx - $A*$mpx)/$n
      $mpy=0.0;$mpyy=0.0;$my=0.0;$mpyx=0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) {
        $mpy += $flat[$k+1]; $mpyy += $flat[$k+1]*$flat[$k+1]
        $my  += $flat[$k+3]; $mpyx += $flat[$k+1]*$flat[$k+3]
      }
      $den2 = $n*$mpyy - $mpy*$mpy
      if ([Math]::Abs($den2) -lt 1e-9) { continue }
      $D = ($n*$mpyx - $mpy*$my)/$den2
      $E = ($my - $D*$mpy)/$n
      $err = 0.0; $mxE = 0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) {
        $dx = $A*$flat[$k] + $B - $flat[$k+2]
        $dy = $D*$flat[$k+1] + $E - $flat[$k+3]
        $e = [Math]::Sqrt($dx*$dx+$dy*$dy); $err += $e; if ($e -gt $mxE) { $mxE = $e }
      }
      $avg = $err/$n
      if ($null -eq $best -or $avg -lt $best.avg) {
        $best = [pscustomobject]@{ avg=$avg; max=$mxE; p1=$p1; p2=$p2; lon0=$lon0; A=$A; B=$B; D=$D; E=$E }
      }
    }
  }
}

Write-Output ("FIT avg={0:N2}px max={1:N2}px parallels={2}/{3} lon0={4} A={5:N6} B={6:N3} D={7:N6} E={8:N3}" -f $best.avg,$best.max,$best.p1,$best.p2,$best.lon0,$best.A,$best.B,$best.D,$best.E)

$destSpec = @"
yosemite -119.5333 37.7459 ca
grandcanyon -112.1129 36.1069 az
zion -112.9481 37.2982 ut
yellowstone -110.5885 44.4280 wy
glacier -113.4218 48.7742 mt
rainier -121.7603 46.8523 wa
craterlake -122.1090 42.9446 or
superior -90.5824 46.7867 mi
niagara -79.0377 43.0896 ny
acadia -68.2188 44.4072 me
horseshoe -111.5107 36.8791 az
monument -110.0989 37.0041 az
bryce -112.1677 37.6283 ut
antelope -111.3743 36.8619 az
joshua -116.3131 34.1347 ca
tahoe -120.0324 39.0968 ca
brooklyn -73.9442 40.6782 ny
chicago -87.6298 41.8781 il
neworleans -90.0715 29.9511 la
miami -80.1918 25.7617 fl
seattle -122.3321 47.6062 wa
sf -122.4194 37.7749 ca
denver -104.9903 39.7392 co
boston -71.0589 42.3601 ma
portland -122.6765 45.5231 or
delaware -75.0500 39.7000 de
"@

$lines = New-Object System.Collections.ArrayList
$fail = 0; $total = 0
foreach ($line in ($destSpec -split "`n")) {
  $t = $line.Trim()
  if (-not $t) { continue }
  $w = $t -split '\s+'
  $q = Proj ([double]::Parse($w[1],$inv)) ([double]::Parse($w[2],$inv)) $best.p1 $best.p2 $best.lon0
  $px = $best.A * $q[0] + $best.B
  $py = $best.D * $q[1] + $best.E
  $b = $boxes[$w[3]]
  $total++
  $ok = ($px -ge $b[0]-10 -and $px -le $b[2]+10 -and $py -ge $b[1]-10 -and $py -le $b[3]+10)
  if (-not $ok) { $fail++ }
  [void]$lines.Add(("    {0}: {{ x: {1}, y: {2} }}," -f $w[0], [Math]::Round($px,2).ToString($inv), [Math]::Round($py,2).ToString($inv)))
  Write-Output ("{0,-12} {1,-4} svg=({2,7:N1},{3,6:N1}) pct=({4,6:N2}%,{5,6:N2}%) {6}" -f $w[0],$w[3],$px,$py,($px/959*100),($py/593*100),$(if($ok){"ok"}else{"OUT"}))
}
Write-Output "out-of-bbox: $fail / $total"

$out = @"
  // Pin coordinates in the Blank_US_Map SVG space (959x593).
  // Albers conic projection, parallels $($best.p1)/$($best.p2), central meridian $($best.lon0).
  // Fitted against 48 state bounding boxes; average residual $([Math]::Round($best.avg,2)) px.
  const PINS = {
$($lines -join "`n")
  };
"@
[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\pins.js", $out)
Write-Output "pins.js written"
