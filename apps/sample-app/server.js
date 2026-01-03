// apps/sample-app/server.js
const http = require("http");

// Correct path to shared metrics
const { client, trackHttpRequest } = require("../../src/metrics");

const port = process.env.PORT || 3000;

const server = http.createServer(async (req, res) => {
  const path = (req.url || "").split("?")[0];

  // 🔍 Track every request
  res.on("finish", () => {
    trackHttpRequest({
      method: req.method,
      route: path,
      statusCode: res.statusCode,
    });
  });

  if (path === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ status: "ok" }));
  }

  if (path === "/metrics") {
    const metrics = await client.register.metrics();
    res.writeHead(200, { "Content-Type": client.register.contentType });
    return res.end(metrics);
  }

  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("VulcanPaaS sample app is running.\n");
});

server.listen(port, () => {
  console.log(`sample-app listening on port ${port}`);
});