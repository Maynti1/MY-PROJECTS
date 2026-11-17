# Correct SVG path parser + Albers projection fit + point-in-polygon validation.
# Output: pin coordinates in the Blank_US_Map SVG coordinate space.

$ErrorActionPreference = "Stop"

# ---------- path parsing into subpath rings ----------
function Parse-Path([string]$d) {
  $rings = New-Object System.Collections.ArrayList
  $cur   = New-Object System.Collections.Generic.List[double]
  $sx = 0.0; $sy = 0.0; $x = 0.0; $y = 0.0
  $cmd = ''; $started = $false

  $tok = [regex]::Matches($d, '([a-zA-Z])|(-?\d*\.?\d+(?:[eE][-+]?\d+)?)')
  $i = 0
  $nums = New-Object System.Collections.Generic.List[double]

  $flush = {
    param($c, $nums)
    if ($nums.Count -eq 0) { return }
    $n = $nums.ToArray()
    switch ($c) {
      'M' { for ($k = 0; $k -lt $nums.Count; $k += 2) { $x = [double]$n[$k]; $y = [double]$n[$k+1]; $cur.Add([double]$x); $cur.Add([double]$y); if ($k -eq 0) { $sx = $x; $sy = $y } } }
      'm' { for ($k = 0; $k -lt $nums.Count; $k += 2) { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1]; $cur.Add([double]$x); $cur.Add([double]$y); if ($k -eq 0) { $sx = $x; $sy = $y } } }
      'L' { for ($k = 0; $k -lt $nums.Count; $k += 2) { $x = [double]$n[$k]; $y = [double]$n[$k+1]; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'l' { for ($k = 0; $k -lt $nums.Count; $k += 2) { $x = $x + [double]$n[$k]; $y = $y + [double]$n[$k+1]; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'H' { foreach ($v in $n) { $x = [double]$v; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'h' { foreach ($v in $n) { $x = $x + [double]$v; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'V' { foreach ($v in $n) { $y = [double]$v; $cur.Add([double]$x); $cur.Add([double]$y) } }
      'v' { foreach ($v in $n) { $y = $y + [double]$v; $cur.Add([double]$x); $cur.Add([double]$y) } }
    }
  }

  foreach ($t in $tok) {
    if ($t.Groups[1].Success) {
      if ($cmd -ne '') { & $flush $cmd $nums; $nums.Clear() }
      $c = $t.Groups[1].Value
      if ($c -eq 'Z' -or $c -eq 'z') {
        if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
        $cur = New-Object System.Collections.Generic.List[double]
        $x = $sx; $y = $sy; $cmd = ''; $started = $false
        continue
      }
      $cmd = $c
      # after a moveto, subsequent implicit pairs are linetos
      if ($cmd -eq 'M') { $cmd = 'M'; $pendingMoveto = $true }
    } else {
      $nums.Add([double]$t.Groups[2].Value)
    }
  }
  if ($cmd -ne '') { & $flush $cmd $nums }
  if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
  return ,$rings
}

# The "implicit lineto after moveto" rule needs special handling, so re-implement
# with an explicit command-normalising pass.
function Parse-Path2([string]$d) {
  $tokens = [regex]::Matches($d, '([a-zA-Z])|(-?\d*\.?\d+(?:[eE][-+]?\d+)?)')
  $rings = New-Object System.Collections.ArrayList
  $cur = New-Object System.Collections.Generic.List[double]
  $sx = 0.0; $sy = 0.0; $x = 0.0; $y = 0.0
  $cmd = ''
  $nums = New-Object System.Collections.Generic.List[double]
  $prevCmd = ''

  function FlushIt([string]$c, $nums, [ref]$x, [ref]$y, [ref]$sx, [ref]$sy, $cur) {
    if ($nums.Count -eq 0) { return }
    $n = $nums.ToArray()
    $cnt = $nums.Count
    switch ($c) {
      'M' { for ($k = 0; $k -lt $cnt; $k += 2) { $x.Value = [double]$n[$k]; $y.Value = [double]$n[$k+1]; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value); if ($k -eq 0) { $sx.Value = $x.Value; $sy.Value = $y.Value } } }
      'm' { for ($k = 0; $k -lt $cnt; $k += 2) { $x.Value = $x.Value + [double]$n[$k]; $y.Value = $y.Value + [double]$n[$k+1]; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value); if ($k -eq 0) { $sx.Value = $x.Value; $sy.Value = $y.Value } } }
      'L' { for ($k = 0; $k -lt $cnt; $k += 2) { $x.Value = [double]$n[$k]; $y.Value = [double]$n[$k+1]; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
      'l' { for ($k = 0; $k -lt $cnt; $k += 2) { $x.Value = $x.Value + [double]$n[$k]; $y.Value = $y.Value + [double]$n[$k+1]; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
      'H' { foreach ($v in $n) { $x.Value = [double]$v; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
      'h' { foreach ($v in $n) { $x.Value = $x.Value + [double]$v; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
      'V' { foreach ($v in $n) { $y.Value = [double]$v; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
      'v' { foreach ($v in $n) { $y.Value = $y.Value + [double]$v; $cur.Add([double]$x.Value); $cur.Add([double]$y.Value) } }
    }
  }

  foreach ($t in $tokens) {
    if ($t.Groups[1].Success) {
      if ($cmd -ne '') { FlushIt $cmd $nums ([ref]$x) ([ref]$y) ([ref]$sx) ([ref]$sy) $cur; $nums.Clear() }
      $new = $t.Groups[1].Value
      if ($new -eq 'Z' -or $new -eq 'z') {
        if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
        $cur = New-Object System.Collections.Generic.List[double]
        $x = $sx; $y = $sy
        $cmd = ''
        continue
      }
      # implicit rule: after moveto, extra pairs mean lineto
      $cmd = $new
      $prevCmd = $new
      if ($new -eq 'M' -or $new -eq 'm') { $implicitL = $true } else { $implicitL = $false }
    } else {
      $nums.Add([double]$t.Groups[2].Value)
    }
  }
  if ($cmd -ne '') { FlushIt $cmd $nums ([ref]$x) ([ref]$y) ([ref]$sx) ([ref]$sy) $cur }
  if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
  return ,$rings
}

# ---------- load states ----------
$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")
$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'

$stateRings = @{}
foreach ($m in $stateRe.Matches($raw)) {
  $abbr = $m.Groups[1].Value
  $rings = Parse-Path2 $m.Groups[2].Value
  $stateRings[$abbr] = $rings
}

function Ring-BBox($ring) {
  $minX = [double]::MaxValue; $maxX = [double]::MinValue
  $minY = [double]::MaxValue; $maxY = [double]::MinValue
  for ($i = 0; $i -lt $ring.Count; $i += 2) {
    $px = $ring[$i]; $py = $ring[$i+1]
    if ($px -lt $minX) { $minX = $px }; if ($px -gt $maxX) { $maxX = $px }
    if ($py -lt $minY) { $minY = $py }; if ($py -gt $maxY) { $maxY = $py }
  }
  return @($minX, $minY, $maxX, $maxY)
}

function Ring-Area($ring) {
  $cnt = $ring.Count / 2; $ar = 0.0
  for ($i = 0; $i -lt $cnt; $i++) {
    $j = ($i + 1) % $cnt
    $ar += [double]$ring[2*$i] * [double]$ring[2*$j+1] - [double]$ring[2*$j] * [double]$ring[2*$i+1]
  }
  return [Math]::Abs($ar / 2.0)
}

function Ring-Centroid($ring) {
  $cnt = $ring.Count / 2; $area = 0.0; $cx = 0.0; $cy = 0.0
  for ($i = 0; $i -lt $cnt; $i++) {
    $j = ($i + 1) % $cnt
    $x0 = [double]$ring[2*$i];   $y0 = [double]$ring[2*$i+1]
    $x1 = [double]$ring[2*$j];   $y1 = [double]$ring[2*$j+1]
    $cr = $x0*$y1 - $x1*$y0
    $area += $cr; $cx += ($x0+$x1)*$cr; $cy += ($y0+$y1)*$cr
  }
  $area = $area / 2.0
  if ([Math]::Abs($area) -lt 1e-9) { return $null }
  return @([double]($cx/(6.0*$area)), [double]($cy/(6.0*$area)))
}

function Point-InRing([double]$px, [double]$py, $ring) {
  $inside = $false
  $cnt = $ring.Count / 2
  $j = $cnt - 1
  for ($i = 0; $i -lt $cnt; $i++) {
    $xi = [double]$ring[2*$i];   $yi = [double]$ring[2*$i+1]
    $xj = [double]$ring[2*$j];   $yj = [double]$ring[2*$j+1]
    if ((($yi -gt $py) -ne ($yj -gt $py)) -and ($px -lt ($xj-$xi)*($py-$yi)/($yj-$yi) + $xi)) { $inside = -not $inside }
    $j = $i
  }
  return $inside
}

function State-Contains([string]$abbr, [double]$px, [double]$py) {
  if (-not $stateRings.ContainsKey($abbr)) { return $false }
  foreach ($r in $stateRings[$abbr]) {
    if (Ring-Area $r -le 0) { continue }
    if (Point-InRing $px $py $r) { return $true }
  }
  return $false
}

# sanity: print a few bboxes we can eyeball
Write-Output "--- sanity bboxes ---"
foreach ($k in @('al','ca','tx','ny','fl','me','wa','ak','hi','nd')) {
  $rings = $stateRings[$k]
  $best = $null; $bestA = 0.0
  foreach ($r in $rings) { $a = Ring-Area $r; if ($a -gt $bestA) { $bestA = $a; $best = $r } }
  $b = Ring-BBox $best
  Write-Output ("{0}: x {1,7:N1}..{2,7:N1}  y {3,7:N1}..{4,7:N1}  area={5:N0}" -f $k,$b[0],$b[2],$b[1],$b[3],$bestA)
}
Write-Output "--- expected (visual): CA ~x25..80 y120..300 ; TX ~x330..470 y250..440 ; NY ~x800..875 y60..180 ; FL ~x760..900 y400..500 ---"
