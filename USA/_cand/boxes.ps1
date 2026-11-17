# Computes SVG-space bboxes for every state from the Blank_US_Map paths.
# Pin positions are then defined as a fraction of a state's bbox, which is
# exact by construction (no projection guesswork).

$ErrorActionPreference = "Stop"
$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")
$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'

$boxes = @{}

foreach ($m in $stateRe.Matches($raw)) {
  $abbr = $m.Groups[1].Value
  $d    = $m.Groups[2].Value

  $minX = [double]::MaxValue; $maxX = [double]::MinValue
  $minY = [double]::MaxValue; $maxY = [double]::MinValue

  $tokens = [regex]::Matches($d, '([mlhvzMLHVZ])|(-?\d*\.?\d+)')
  $cmd  = ''
  $nums = New-Object System.Collections.Generic.List[double]
  $x = 0.0; $y = 0.0

  foreach ($t in $tokens) {
    if ($t.Groups[1].Success) {
      if ($cmd -ne '' -and $nums.Count -gt 0) {
        $n = $nums.ToArray()
        switch ($cmd.ToLower()) {
          'm' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'm') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] } } }
          'l' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'l') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] } } }
          'h' { foreach ($v in $n) { if ($cmd -eq 'h') { $x = [double]$v } else { $x += [double]$v } } }
          'v' { foreach ($v in $n) { if ($cmd -eq 'v') { $y = [double]$v } else { $y += [double]$v } } }
        }
        $nums.Clear()
      }
      $cmd = $t.Groups[1].Value
    } else {
      $nums.Add([double]$t.Groups[2].Value)
    }
  }
  if ($cmd -ne '' -and $nums.Count -gt 0) {
    $n = $nums.ToArray()
    switch ($cmd.ToLower()) {
      'm' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'm') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] } } }
      'l' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'l') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] } } }
      'h' { foreach ($v in $n) { if ($cmd -eq 'h') { $x = [double]$v } else { $x += [double]$v } } }
      'v' { foreach ($v in $n) { if ($cmd -eq 'v') { $y = [double]$v } else { $y += [double]$v } } }
    }
  }

  # second pass over raw numbers is not enough (need resolved coordinates),
  # so re-run tracking min/max per resolved point
  $minX = [double]::MaxValue; $maxX = [double]::MinValue
  $minY = [double]::MaxValue; $maxY = [double]::MinValue
  $tokens = [regex]::Matches($d, '([mlhvzMLHVZ])|(-?\d*\.?\d+)')
  $cmd  = ''; $nums.Clear(); $x = 0.0; $y = 0.0
  foreach ($t in $tokens) {
    if ($t.Groups[1].Success) {
      if ($cmd -ne '' -and $nums.Count -gt 0) {
        $n = $nums.ToArray()
        $pts = @()
        switch ($cmd.ToLower()) {
          'm' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'm') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] }; $pts += ,@($x,$y) } }
          'l' { for ($k = 0; $k -lt $nums.Count; $k += 2) { if ($cmd -eq 'l') { $x = [double]$n[$k]; $y = [double]$n[$k+1] } else { $x += [double]$n[$k]; $y += [double]$n[$k+1] }; $pts += ,@($x,$y) } }
          'h' { foreach ($v in $n) { if ($cmd -eq 'h') { $x = [double]$v } else { $x += [double]$v }; $pts += ,@($x,$y) } }
          'v' { foreach ($v in $n) { if ($cmd -eq 'v') { $y = [double]$v } else { $y += [double]$v }; $pts += ,@($x,$y) } }
        }
        foreach ($p in $pts) {
          if ($p[0] -lt $minX) { $minX = $p[0] }; if ($p[0] -gt $maxX) { $maxX = $p[0] }
          if ($p[1] -lt $minY) { $minY = $p[1] }; if ($p[1] -gt $maxY) { $maxY = $p[1] }
        }
        $nums.Clear()
      }
      $cmd = $t.Groups[1].Value
    } else {
      $nums.Add([double]$t.Groups[2].Value)
    }
  }

  if ($minX -le $maxX) {
    $boxes[$abbr] = @($minX, $minY, $maxX, $maxY)
  }
}

Write-Output "boxes: $($boxes.Count)"
foreach ($k in @('ca','tx','fl','ny','wa','mt','nd','ak','hi','me','wa')) {
  if ($boxes.ContainsKey($k)) {
    $b = $boxes[$k]
    Write-Output ("{0}: x {1:N1}..{2:N1}  y {3:N1}..{4:N1}" -f $k,$b[0],$b[2],$b[1],$b[3])
  }
}

$lines = @()
foreach ($k in ($boxes.Keys | Sort-Object)) {
  $b = $boxes[$k]
  $lines += ("    {0}: [{1:N2}, {2:N2}, {3:N2}, {4:N2}]," -f $k,$b[0],$b[1],$b[2],$b[3])
}
$out = "  const STATE_BOX = {`n$($lines -join "`n")`n  };"
[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\state-boxes.js", $out)
Write-Output "state-boxes.js written"
