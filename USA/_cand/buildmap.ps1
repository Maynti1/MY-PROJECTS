$raw = Get-Content "D:\My works pages\USA\_cand\us-states.svg" -Raw

# --- extract state paths ---
$stateRe = [regex]'<path class="([a-z]{2})" d="([^"]+)"\s*>'
$states = @{}
foreach ($m in $stateRe.Matches($raw)) {
  $states[$m.Groups[1].Value] = $m.Groups[2].Value
}

# --- extract border paths ---
$borderRe = [regex]'<path class="([a-z]{2}-[a-z]{2})" d="([^"]+)"\s*/?>'
$borders = @{}
foreach ($m in $borderRe.Matches($raw)) {
  $borders[$m.Groups[1].Value] = $m.Groups[2].Value
}

$names = @{
  al="Alabama"; ak="Alaska"; az="Arizona"; ar="Arkansas"; ca="California"; co="Colorado"; ct="Connecticut";
  de="Delaware"; fl="Florida"; ga="Georgia"; hi="Hawaii"; id="Idaho"; il="Illinois"; in="Indiana"; ia="Iowa";
  ks="Kansas"; ky="Kentucky"; la="Louisiana"; me="Maine"; md="Maryland"; ma="Massachusetts"; mi="Michigan";
  mn="Minnesota"; ms="Mississippi"; mo="Missouri"; mt="Montana"; ne="Nebraska"; nv="Nevada"; nh="New Hampshire";
  nj="New Jersey"; nm="New Mexico"; ny="New York"; nc="North Carolina"; nd="North Dakota"; oh="Ohio";
  ok="Oklahoma"; or="Oregon"; pa="Pennsylvania"; ri="Rhode Island"; sc="South Carolina"; sd="South Dakota";
  tn="Tennessee"; tx="Texas"; ut="Utah"; vt="Vermont"; va="Virginia"; wa="Washington"; wv="West Virginia";
  wi="Wisconsin"; wy="Wyoming"; dc="District of Columbia"
}

$west     = @("wa","or","ca","nv","id","mt","wy","ut","co","az","nm","ak","hi")
$south    = @("tx","ok","ar","la","ms","al","tn","ky","ga","fl","sc","nc","va","wv","md","de","dc")
$midwest  = @("nd","sd","ne","ks","mn","ia","mo","wi","il","in","mi","oh")
$northeast= @("pa","nj","ny","ct","ri","ma","vt","nh","me")

function Region-Of($s) {
  if ($west -contains $s) { return "west" }
  if ($south -contains $s) { return "south" }
  if ($midwest -contains $s) { return "midwest" }
  if ($northeast -contains $s) { return "northeast" }
  return "other"
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<svg class="us-svg" viewBox="0 0 959 593" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="usMapTitle">')
[void]$sb.AppendLine('  <title id="usMapTitle">Map of the United States with highlighted regions</title>')
[void]$sb.AppendLine('  <g class="us-states">')

foreach ($key in ($states.Keys | Sort-Object)) {
  $r = Region-Of $key
  $title = $names[$key]
  [void]$sb.AppendLine("    <path class=`"st st--$r`" data-state=`"$key`" d=`"$($states[$key])`"><title>$title</title></path>")
}

[void]$sb.AppendLine('  </g>')
[void]$sb.AppendLine('  <g class="us-borders">')
foreach ($key in ($borders.Keys | Sort-Object)) {
  [void]$sb.AppendLine("    <path d=`"$($borders[$key])`"/>")
}
[void]$sb.AppendLine('  </g>')
[void]$sb.AppendLine('</svg>')

$out = $sb.ToString()
$path = "D:\My works pages\USA\_cand\us-map-inline.html"
[System.IO.File]::WriteAllText($path, $out)
Write-Output "states: $($states.Count)  borders: $($borders.Count)  bytes: $((Get-Item $path).Length)"
