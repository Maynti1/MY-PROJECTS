$ErrorActionPreference = "Stop"
$root = "D:\My works pages\USA"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:4183/")
$listener.Start()
Write-Output "Serving $root on http://127.0.0.1:4183/"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  try {
    $path = $context.Request.Url.LocalPath.TrimStart("/")
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "index.html" }
    $file = Join-Path $root $path

    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
      $mime = switch ($ext) {
        ".html" { "text/html; charset=utf-8" }
        ".css"  { "text/css; charset=utf-8" }
        ".js"   { "application/javascript; charset=utf-8" }
        ".json" { "application/json; charset=utf-8" }
        ".svg"  { "image/svg+xml" }
        ".png"  { "image/png" }
        ".jpg"  { "image/jpeg" }
        ".webp" { "image/webp" }
        ".ico"  { "image/x-icon" }
        default { "application/octet-stream" }
      }
      $context.Response.ContentType = $mime
      $context.Response.Headers.Add("Cache-Control", "no-store")
      $context.Response.ContentLength64 = $bytes.Length
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $context.Response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not found")
      $context.Response.ContentType = "text/plain; charset=utf-8"
      $context.Response.ContentLength64 = $bytes.Length
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
  } catch {
    try { $context.Response.StatusCode = 500 } catch {}
  } finally {
    try { $context.Response.Close() } catch {}
  }
}
