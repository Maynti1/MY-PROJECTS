$ErrorActionPreference = "Stop"

$htmlPath = "D:\My works pages\USA\index.html"
$html = [System.IO.File]::ReadAllText($htmlPath)

$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")

# extract the states group
$start = $raw.IndexOf('<g class="state">')
$end   = $raw.IndexOf('</g>', $start)
$block = $raw.Substring($start, $end - $start)
$block = [regex]::Replace($block, '<!--.*?-->', '', 'Singleline')
$block = [regex]::Replace($block, '<title>.*?</title>', '')

$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"'

$west     = @("wa","or","ca","nv","id","mt","wy","ut","co","az","nm","ak","hi")
$south    = @("tx","ok","ar","la","ms","al","tn","ky","ga","fl","sc","nc","va","wv","md","de","dc")
$midwest  = @("nd","sd","ne","ks","mn","ia","mo","wi","il","in","mi","oh")
$northeast= @("pa","nj","ny","ct","ri","ma","vt","nh","me")

function Get-Region([string]$s) {
  if ($west -contains $s) { return "west" }
  if ($south -contains $s) { return "south" }
  if ($midwest -contains $s) { return "midwest" }
  if ($northeast -contains $s) { return "northeast" }
  return "other"
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<svg class="us-svg" viewBox="0 0 959 593" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="usMapTitle" preserveAspectRatio="xMidYMid meet">')
[void]$sb.AppendLine('  <g class="us-states">')
foreach ($m in $stateRe.Matches($block)) {
  $abbr = $m.Groups[1].Value
  $d = $m.Groups[2].Value
  $r = Get-Region $abbr
  [void]$sb.AppendLine("    <path class=`"st st--$r`" data-state=`"$abbr`" d=`"$d`"/>")
}
[void]$sb.AppendLine('  </g>')
[void]$sb.AppendLine('</svg>')

$svg = $sb.ToString()
$html = $html.Replace('<!--US_MAP_SVG-->', $svg.TrimEnd())
[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Output "map injected: $($svg.Length) chars; html now $((Get-Item $htmlPath).Length) bytes"
