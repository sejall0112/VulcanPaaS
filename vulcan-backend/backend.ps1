# backend.ps1 - simple local backend for VulcanPaaS
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:5000/")
$listener.Start()

Write-Host "Listening on http://localhost:5000/  (Press Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()

    $msg = "Vulcan backend OK"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($msg)

    $context.Response.StatusCode = 200
    $context.Response.ContentType = "text/plain"
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
  }
}
finally {
  $listener.Stop()
  $listener.Close()
}