const root = require("heroku-env");
try {
  root("& touch heroku-env", "aa", function () {});
} catch (err) {}
