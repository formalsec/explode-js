const diskstats = require("diskstats");

try {
  diskstats.check("; touch diskstats", () => {});
} catch (err) {}
