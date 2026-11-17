$ErrorActionPreference = "Stop"
$raw = [System.IO.File]::ReadAllText("D:\My works pages\USA\_cand\us-states.svg")

# keep only the <g class="state"> block, strip comments
$start = $raw.IndexOf('<g class="state">')
$end   = $raw.IndexOf('</g>', $start)
$block = $raw.Substring($start, $end - $start)
$block = [regex]::Replace($block, '<!--.*?-->', '', 'Singleline')
$block = $block -replace '<title>.*?</title>', ''

$svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 959 593" id="map">' + $block + '</svg>'

$js = @'
(function () {
  const svg = document.getElementById('map');
  const paths = Array.from(svg.querySelectorAll('path'));

  // exact centroid of a path via sampling
  function centroid(p) {
    const L = p.getTotalLength();
    const N = 400;
    let a = 0, cx = 0, cy = 0;
    for (let i = 0; i < N; i++) {
      const t0 = i / N, t1 = (i + 1) / N;
      const p0 = p.getPointAtLength(L * t0);
      const p1 = p.getPointAtLength(L * t1);
      const cr = p0.x * p1.y - p1.x * p0.y;
      a += cr; cx += (p0.x + p1.x) * cr; cy += (p0.y + p1.y) * cr;
    }
    a /= 2;
    if (Math.abs(a) < 1e-9) return null;
    return { x: cx / (6 * a), y: cy / (6 * a) };
  }

  const stateC = {};
  for (const p of paths) {
    const ab = p.getAttribute('data-state') || (p.getAttribute('class') || '').split(/\s+/)[0];
    const c = centroid(p);
    if (c) stateC[ab] = c;
  }

  // reference: geographic centroid of each state (lon, lat)
  const REF = {
    wy:[-107.6,43.0], co:[-105.6,39.0], nd:[-100.4,47.5], sd:[-100.1,44.4],
    ne:[-99.8,41.9], ks:[-98.4,38.5], ok:[-97.5,35.6], nm:[-106.1,34.3],
    az:[-111.7,34.3], ut:[-111.7,39.3], nv:[-116.9,39.5], id:[-114.6,44.2],
    mt:[-109.6,46.9], or:[-120.6,43.9], wa:[-120.7,47.4], tx:[-99.3,31.1],
    mn:[-94.3,46.3], ia:[-93.5,42.1], il:[-89.2,40.1], wi:[-89.7,44.6],
    mo:[-92.5,38.4], ky:[-85.3,37.5], tn:[-86.3,35.8], nc:[-79.5,35.6],
    sc:[-80.9,33.9], ga:[-83.4,32.6], al:[-86.8,32.8], ms:[-89.7,32.7],
    la:[-92.0,31.0], ar:[-92.4,34.9], mi:[-85.4,44.3], oh:[-82.8,40.3],
    va:[-78.7,37.5], pa:[-77.8,40.9], ny:[-75.5,42.9], me:[-69.2,45.3],
    vt:[-72.7,44.1], nh:[-71.6,43.7], ma:[-71.8,42.3], ct:[-72.7,41.6],
    nj:[-74.5,40.1], md:[-76.7,39.0], de:[-75.5,39.0], wv:[-80.6,38.6]
  };

  const RAD = Math.PI / 180;
  function albers(lon, lat, p1, p2, lon0) {
    const f1 = p1*RAD, f2 = p2*RAD, fl = lat*RAD, ll = lon*RAD;
    const n = (Math.sin(f1) + Math.sin(f2)) / 2;
    const C = Math.cos(f1)*Math.cos(f1) + 2*n*Math.sin(f1);
    const rho = Math.sqrt(C - 2*n*Math.sin(fl)) / n;
    const rho0 = Math.sqrt(C) / n;
    const theta = n * (ll - lon0*RAD);
    return [rho*Math.sin(theta), rho0 - rho*Math.cos(theta)];
  }

  function fit(p1, p2, lon0) {
    const pts = [];
    for (const k in REF) {
      if (!stateC[k]) continue;
      const q = albers(REF[k][0], REF[k][1], p1, p2, lon0);
      pts.push([q[0], q[1], stateC[k].x, stateC[k].y]);
    }
    if (pts.length < 20) return null;
    const n = pts.length;
    let sx=0, sxx=0, mx=0, sxy=0;
    for (const p of pts) { sx+=p[0]; sxx+=p[0]*p[0]; mx+=p[2]; sxy+=p[0]*p[2]; }
    const den = n*sxx - sx*sx;
    if (Math.abs(den) < 1e-9) return null;
    const A = (n*sxy - sx*mx) / den;
    const B = (mx - A*sx) / n;
    let sy=0, syy=0, my=0, syx=0;
    for (const p of pts) { sy+=p[1]; syy+=p[1]*p[1]; my+=p[3]; syx+=p[1]*p[3]; }
    const den2 = n*syy - sy*sy;
    if (Math.abs(den2) < 1e-9) return null;
    const D = (n*syx - sy*my) / den2;
    const E = (my - D*sy) / n;
    let err = 0, max = 0;
    for (const p of pts) {
      const dx = A*p[0] + B - p[2], dy = D*p[1] + E - p[3];
      const e = Math.hypot(dx, dy); err += e; if (e > max) max = e;
    }
    return { avg: err/n, max, A, B, D, E, n };
  }

  let best = null;
  for (let p1 = 28.5; p1 <= 30.6; p1 += 0.25)
   for (let p2 = 44.4; p2 <= 46.6; p2 += 0.25)
    for (let lon0 = -99; lon0 <= -93; lon0 += 0.25) {
      const f = fit(p1, p2, lon0);
      if (f && (!best || f.avg < best.avg)) best = Object.assign({p1,p2,lon0}, f);
    }

  const DEST = {
    yosemite:[-119.5333,37.7459], grandcanyon:[-112.1129,36.1069], zion:[-112.9481,37.2982],
    yellowstone:[-110.5885,44.4280], glacier:[-113.4218,48.7742], rainier:[-121.7603,46.8523],
    craterlake:[-122.1090,42.9446], superior:[-90.5824,46.7867], niagara:[-79.0377,43.0896],
    acadia:[-68.2188,44.4072], horseshoe:[-111.5107,36.8791], monument:[-110.0989,37.0041],
    bryce:[-112.1677,37.6283], antelope:[-111.3743,36.8619], joshua:[-116.3131,34.1347],
    tahoe:[-120.0324,39.0968], brooklyn:[-73.9442,40.6782], chicago:[-87.6298,41.8781],
    neworleans:[-90.0715,29.9511], miami:[-80.1918,25.7617], seattle:[-122.3321,47.6062],
    sf:[-122.4194,37.7749], denver:[-104.9903,39.7392], boston:[-71.0589,42.3601],
    portland:[-122.6765,45.5231], delaware:[-75.05,39.7]
  };

  const pins = {};
  for (const k in DEST) {
    const q = albers(DEST[k][0], DEST[k][1], best.p1, best.p2, best.lon0);
    pins[k] = {
      x: +(best.A*q[0] + best.B).toFixed(2),
      y: +(best.D*q[1] + best.E).toFixed(2)
    };
  }

  window.__RESULT__ = { best: {avg:+best.avg.toFixed(2), max:+best.max.toFixed(2), p1:best.p1, p2:best.p2, lon0:best.lon0, A:best.A, B:best.B, D:best.D, E:best.E, n:best.n}, pins, stateC };
})();
'@

$html = @"
<!doctype html>
<html><head><meta charset="utf-8"><title>calib</title>
<style>body{margin:0;background:#111}#map{width:959px;height:593px}path{fill:#ccc}</style>
</head><body>
$svg
<script>
$js
</script>
</body></html>
"@

[System.IO.File]::WriteAllText("D:\My works pages\USA\_cand\calib.html", $html)
Write-Output "calib.html written: $((Get-Item 'D:\My works pages\USA\_cand\calib.html').Length) bytes"
