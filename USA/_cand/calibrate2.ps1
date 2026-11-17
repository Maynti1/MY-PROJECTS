# Calibrates the Blank_US_Map SVG projection using exact polygon centroids
# (not bounding boxes) and validates every pin with a point-in-polygon test.

$ErrorActionPreference = "Stop"
$inv = [System.Globalization.CultureInfo]::InvariantCulture
$rad = [Math]::PI / 180.0

# ============ 1. parse state paths into rings ============
function Parse-Rings([string]$d) {
  $rings = New-Object System.Collections.ArrayList
  $cur   = New-Object System.Collections.Generic.List[double]
  $sx = 0.0; $sy = 0.0; $x = 0.0; $y = 0.0
  $tokens = [regex]::Matches($d, '([a-zA-Z])|(-?\d*\.?\d+(?:[eE][-+]?\d+)?)')
  $i = 0
  while ($i -lt $tokens.Count) {
    $t = $tokens[$i]
    if (-not $t.Groups[1].Success) { $i++; continue }
    $c = $t.Groups[1].Value
    if ($c -eq 'z' -or $c -eq 'Z') {
      if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
      $cur = New-Object System.Collections.Generic.List[double]
      $x = $sx; $y = $sy
      $i++
      continue
    }
    $abs = ($c -ceq $c.ToUpperInvariant())
    $cmd = $c.ToUpperInvariant()
    $i++
    $nums = New-Object System.Collections.Generic.List[double]
    while ($i -lt $tokens.Count -and -not $tokens[$i].Groups[1].Success) {
      $nums.Add([double]$tokens[$i].Groups[2].Value); $i++
    }
    $n = $nums.ToArray(); $cnt = $nums.Count
    switch ($cmd) {
      'M' {
        if ($cnt -ge 2) {
          if ($abs) { $x = $n[0]; $y = $n[1] } else { $x += $n[0]; $y += $n[1] }
          $sx = $x; $sy = $y
          $cur.Add([double]$x); $cur.Add([double]$y)
          for ($k = 2; $k + 1 -lt $cnt; $k += 2) {
            if ($abs) { $x = $n[$k]; $y = $n[$k+1] } else { $x += $n[$k]; $y += $n[$k+1] }
            $cur.Add([double]$x); $cur.Add([double]$y)
          }
        }
      }
      'L' { for ($k = 0; $k + 1 -lt $cnt; $k += 2) { if ($abs) { $x = $n[$k]; $y = $n[$k+1] } else { $x += $n[$k]; $y += $n[$k+1] }; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'H' { foreach ($v in $n) { if ($abs) { $x = $v } else { $x += $v }; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'V' { foreach ($v in $n) { if ($abs) { $y = $v } else { $y += $v }; $cur.Add([double]$x); $cur.Add([double]$y) } }
    }
  }
  if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
  return ,$rings
}

function Ring-Area([double[]]$ring) {
  $cnt = [int]($ring.Count/2); $ar = 0.0
  for ($i = 0; $i -lt $cnt; $i++) {
    $j = ($i + 1) % $cnt
    $ar += $ring[2*$i]*$ring[2*$j+1] - $ring[2*$j]*$ring[2*$i+1]
  }
  return $ar/2.0
}

function Ring-Centroid([double[]]$ring) {
  $cnt = [int]($ring.Count/2); $a = 0.0; $cx = 0.0; $cy = 0.0
  for ($i = 0; $i -lt $cnt; $i++) {
    $j = ($i + 1) % $cnt
    $x0 = $ring[2*$i]; $y0 = $ring[2*$i+1]; $x1 = $ring[2*$j]; $y1 = $ring[2*$j+1]
    $cr = $x0*$y1 - $x1*$y0
    $a += $cr; $cx += ($x0+$x1)*$cr; $cy += ($y0+$y1)*$cr
  }
  $a = $a/2.0
  if ([Math]::Abs($a) -lt 1e-9) { return $null }
  return @([double]($cx/(6.0*$a)), [double]($cy/(6.0*$a)))
}

function Point-InRing([double]$px, [double]$py, [double[]]$ring) {
  $inside = $false
  $cnt = [int]($ring.Count/2)
  $j = $cnt - 1
  for ($i = 0; $i -lt $cnt; $i++) {
    $xi = $ring[2*$i]; $yi = $ring[2*$i+1]
    $xj = $ring[2*$j]; $yj = $ring[2*$j+1]
    if ((($yi -gt $py) -ne ($yj -gt $py)) -and ($px -lt ($xj-$xi)*($py-$yi)/($yj-$yi) + $xi)) { $inside = -not $inside }
    $j = $i
  }
  return $inside
}

$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")
$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'

$stateRings = @{}      # abbr -> double[][] of rings
$stateCent  = @{}      # abbr -> centroid (x,y)

foreach ($m in $stateRe.Matches($raw)) {
  $abbr = $m.Groups[1].Value
  $rings = Parse-Rings $m.Groups[2].Value
  $stateRings[$abbr] = $rings
  $best = $null; $bestA = 0.0
  foreach ($r in $rings) {
    $a = [Math]::Abs((Ring-Area $r))
    if ($a -gt $bestA) { $bestA = $a; $best = $r }
  }
  if ($best -ne $null) {
    $c = Ring-Centroid $best
    if ($c -ne $null) { $stateCent[$abbr] = @([double]$c[0], [double]$c[1]) }
  }
}
Write-Output "states parsed: $($stateRings.Count)  centroids: $($stateCent.Count)"

function State-Has([string]$abbr, [double]$px, [double]$py) {
  if (-not $stateRings.ContainsKey($abbr)) { return $false }
  foreach ($r in $stateRings[$abbr]) {
    if ([Math]::Abs((Ring-Area $r)) -le 0.01) { continue }
    if (Point-InRing $px $py $r) { return $true }
  }
  return $false
}

# ============ 2. Albers projection ============
function Proj([double]$lon, [double]$lat, [double]$p1, [double]$p2, [double]$lon0) {
  $f1 = $p1*$rad; $f2 = $p2*$rad; $fl = $lat*$rad; $ll = $lon*$rad
  $n = ([Math]::Sin($f1) + [Math]::Sin($f2)) / 2.0
  $C = [Math]::Pow([Math]::Cos($f1),2) + 2.0*$n*[Math]::Sin($f1)
  $rho  = [Math]::Sqrt($C - 2.0*$n*[Math]::Sin($fl)) / $n
  $rho0 = [Math]::Sqrt($C) / $n
  $th = $n * ($ll - $lon0*$rad)
  return @([double]($rho*[Math]::Sin($th)), [double]($rho0 - $rho*[Math]::Cos($th)))
}

# ============ 3. reference states: geo centroid vs SVG polygon centroid ============
# Areas with irregular shapes (CA, FL, MI, AK, HI, WV, MD) are excluded because
# their polygon centroid deviates strongly from the geographic centroid.
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
de -75.5 39.0
"@

$ref = New-Object System.Collections.ArrayList
foreach ($line in ($refSpec -split "`n")) {
  $t = $line.Trim(); if (-not $t) { continue }
  $w = $t -split '\s+'
  if (-not $stateCent.ContainsKey($w[0])) { continue }
  $sc = $stateCent[$w[0]]
  [void]$ref.Add([pscustomobject]@{
    st = $w[0]
    lon = [double]::Parse($w[1], $inv)
    lat = [double]::Parse($w[2], $inv)
    sx = [double]$sc[0]; sy = [double]$sc[1]
  })
}
Write-Output "reference states: $($ref.Count)"

# ============ 4. grid search projection params ============
$best = $null
foreach ($p1 in 28.5..31.5) {
  foreach ($p2 in 44.0..47.0) {
    foreach ($lon0 in -99.0..-93.0) {
      $flat = New-Object System.Collections.Generic.List[double]
      foreach ($r in $ref) {
        $q = Proj $r.lon $r.lat $p1 $p2 $lon0
        $flat.Add([double]$q[0]); $flat.Add([double]$q[1]); $flat.Add([double]$r.sx); $flat.Add([double]$r.sy)
      }
      $n = $ref.Count
      $mpx=0.0;$mpxx=0.0;$mx=0.0;$mpxy=0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) { $mpx += $flat[$k]; $mpxx += $flat[$k]*$flat[$k]; $mx += $flat[$k+2]; $mpxy += $flat[$k]*$flat[$k+2] }
      $den = $n*$mpxx - $mpx*$mpx; if ([Math]::Abs($den) -lt 1e-9) { continue }
      $A = ($n*$mpxy - $mpx*$mx)/$den; $B = ($mx - $A*$mpx)/$n
      $mpy=0.0;$mpyy=0.0;$my=0.0;$mpyx=0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) { $mpy += $flat[$k+1]; $mpyy += $flat[$k+1]*$flat[$k+1]; $my += $flat[$k+3]; $mpyx += $flat[$k+1]*$flat[$k+3] }
      $den2 = $n*$mpyy - $mpy*$mpy; if ([Math]::Abs($den2) -lt 1e-9) { continue }
      $D = ($n*$mpyx - $mpy*$my)/$den2; $E = ($my - $D*$mpy)/$n
      $err = 0.0
      for ($k = 0; $k -lt $flat.Count; $k += 4) {
        $dx = $A*$flat[$k] + $B - $flat[$k+2]
        $dy = $D*$flat[$k+1] + $E - $flat[$k+3]
        $err += [Math]::Sqrt($dx*$dx + $dy*$dy)
      }
      $avg = $err/$n
      if ($null -eq $best -or $avg -lt $best.avg) {
        $best = [pscustomobject]@{ avg=$avg; p1=$p1; p2=$p2; lon0=$lon0; A=$A; B=$B; D=$D; E=$E }
      }
    }
  }
}
Write-Output ("FIT avg={0:N2}px  parallels={1}/{2} lon0={3}" -f $best.avg, $best.p1, $best.p2, $best.lon0)

# ============ 5. destinations + validation ============
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
  $t = $line.Trim(); if (-not $t) { continue }
  $w = $t -split '\s+'
  $q = Proj ([double]::Parse($w[1],$inv)) ([double]::Parse($w[2],$inv)) $best.p1 $best.p2 $best.lon0
  $px = $best.A * $q[0] + $best.B
  $py = $best.D * $q[1] + $best.E
  $total++
  $ok = State-Has $w[3] $px $py
  if (-not $ok) { $fail++ }
  [void]$lines.Add(("    {0}: {{ x: {1}, y: {2} }}," -f $w[0], [Math]::Round($px,2).ToString($inv), [Math]::Round($py,2).ToString($inv)))
  Write-Output ("{0,-12} {1,-4} svg=({2,7:N1},{3,6:N1}) pct=({4,6:N2}%,{5,6:N2}%) {6}" -f $w[0],$w[3],$px,$py,($px/959*100),($py/593*100),$(if($ok){"ok"}else{"OUT"}))
}
Write-Output "pins outside their state: $fail / $total"

$out = @"
  // Pin coordinates in the Blank_US_Map SVG space (959x593).
  // Albers conic projection, parallels $($best.p1)/$($best.p2), central meridian $($best.lon0),
  // fitted against $($ref.Count) state polygon centroids (avg residual $([Math]::Round($best.avg,2)) px).
  const PINS = {
$($lines -join "`n")
  };
"@
[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\pins.js", $out)
Write-Output "pins.js written"
