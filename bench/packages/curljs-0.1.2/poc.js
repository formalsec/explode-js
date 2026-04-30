const a = require("curljs");

try {
  a("' & touch curljs # '", function () {});
} catch (err) {}
