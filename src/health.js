function health() {
  return {
    ok: true,
    service: "vulcanpaas",
    timestamp: new Date().toISOString()
  };
}

module.exports = { health };