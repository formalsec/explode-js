const root = require("im-resize");

let image = { path: "& touch im-resize &" };
let output = { versions: [] };
try {
  root(image, output, function () {});
} catch (err) {}
