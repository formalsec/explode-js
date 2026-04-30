const esl = require('esl_symbolic');
const a = require("geojson2kml");
try {
  a(esl.string('payload'), esl.string('payload2'), function (err) {});
} catch (err) {}
