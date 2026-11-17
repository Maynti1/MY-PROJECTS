# Parses the Blank_US_Map SVG state paths into per-state bounding boxes.
# (PowerShell's switch is case-insensitive, so M/m are handled explicitly here.)

$ErrorActionPreference = "Stop"

function Parse-PathRings([string]$d) {
  $rings = New-Object System.Collections.ArrayList
  $cur   = New-Object System.Collections.Generic.List[double]
  $sx = 0.0; $sy = 0.0; $x = 0.0; $y = 0.0
  $cmd = ''; $abs = $true

  $tokens = [regex]::Matches($d, '([a-zA-Z])|(-?\d*\.?\d+(?:[eE][-+]?\d+)?)')

  $i = 0
  while ($i -lt $tokens.Count) {
    $t = $tokens[$i]
    if ($t.Groups[1].Success) {
      $c = $t.Groups[1].Value
      $abs = ($c -ceq [string]$c.ToUpperInvariant())
      $cmd = $c.ToUpperInvariant()
      $i++
      # gather numbers for this command
      $nums = New-Object System.Collections.Generic.List[double]
      while ($i -lt $tokens.Count -and -not $tokens[$i].Groups[1].Success) {
        $nums.Add([double]$tokens[$i].Groups[2].Value)
        $i++
      }
      $n = $nums.ToArray()
      $cnt = $nums.Count

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
        'L' {
          for ($k = 0; $k + 1 -lt $cnt; $k += 2) {
            if ($abs) { $x = $n[$k]; $y = $n[$k+1] } else { $x += $n[$k]; $y += $n[$k+1] }
            $cur.Add([double]$x); $cur.Add([double]$y)
          }
        }
        'H' {
          foreach ($v in $n) {
            if ($abs) { $x = $v } else { $x += $v }
            $cur.Add([double]$x); $cur.Add([double]$y)
          }
        }
        'V' {
          foreach ($v in $n) {
            if ($abs) { $y = $v } else { $y += $v }
            $cur.Add([double]$x); $cur.Add([double]$y)
          }
        }
      }
    } else { $i++ }
  }

  if ($cur.Count -ge 6) { [void]$rings.Add($cur.ToArray()) }
  return ,$rings
}

$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")
$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'

$boxes = @{}
foreach ($m in $stateRe.Matches($raw)) {
  $abbr = $m.Groups[1].Value
  $rings = Parse-PathRings $m.Groups[2].Value
  $minX = [double]::MaxValue; $maxX = [double]::MinValue
  $minY = [double]::MaxValue; $maxY = [double]::MinValue
  foreach ($r in $rings) {
    for ($k = 0; $k -lt $r.Count; $k += 2) {
      $px = $r[$k]; $py = $r[$k+1]
      if ($px -lt $minX) { $minX = $px }; if ($px -gt $maxX) { $maxX = $px }
      if ($py -lt $minY) { $minY = $py }; if ($py -gt $maxY) { $maxY = $py }
    }
  }
  if ($minX -le $maxX) { $boxes[$abbr] = @($minX, $minY, $maxX, $maxY) }
}

Write-Output "states: $($boxes.Count)"
Write-Output "--- sanity ---"
foreach ($k in @('al','ca','tx','ny','fl','me','wa','ak','hi','nd','mt','nv')) {
  if ($boxes.ContainsKey($k)) {
    $b = $boxes[$k]
    Write-Output ("{0}: x {1,7:N1}..{2,7:N1}   y {3,7:N1}..{4,7:N1}" -f $k,$b[0],$b[2],$b[1],$b[3])
  }
}

$lines = @()
foreach ($k in ($boxes.Keys | Sort-Object)) {
  $b = $boxes[$k]
  $lines += ("    {0}: [{1:N2}, {2:N2}, {3:N2}, {4:N2}]," -f $k,$b[0],$b[1],$b[2],$b[3])
}
[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\state-boxes.js", "  const STATE_BOX = {`n$($lines -join "`n")`n  };")
Write-Output "state-boxes.js written"
