const http = require("http");

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ status: "ok" }));
  }

  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("VulcanPaaS sample app is running.\n");
});

server.listen(port, () => {
  console.log(`sample-app listening on port ${port}`);
});