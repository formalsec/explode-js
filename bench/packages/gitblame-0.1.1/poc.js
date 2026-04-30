const a = require("gitblame");
try {
  a("& touch gitblame", function () {});
} catch (err) {}
