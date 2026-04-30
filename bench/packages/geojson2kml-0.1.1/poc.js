const a = require("geojson2kml");
try {
  a("./", "& touch geojson2kml", function (err) {});
} catch (err) {}
