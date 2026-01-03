// vulcanpas/src/metrics.js
const client = require("prom-client");

// Collect default Node.js metrics
client.collectDefaultMetrics();

// Custom counter
const httpRequestsTotal = new client.Counter({
  name: "vulcan_http_requests_total",
  help: "Total HTTP requests",
  labelNames: ["method", "route", "status"],
});

// 🔍 DEBUG + TRACKING (THIS IS THE KEY FIX)
function trackHttpRequest({ method, route, statusCode }) {
  console.log("TRACKED:", method, route, statusCode);

  httpRequestsTotal.inc({
    method: method || "UNKNOWN",
    route: route || "UNKNOWN",
    status: String(statusCode || 0),
  });
}

// (Kept for future Express usage)
function metricsMiddleware(req, res, next) {
  res.on("finish", () => {
    const route = req.route?.path || req.path;
    trackHttpRequest({ method: req.method, route, statusCode: res.statusCode });
  });
  next();
}

async function metricsHandler(req, res) {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
}

module.exports = {
  client,
  trackHttpRequest,
  metricsMiddleware,
  metricsHandler,
};