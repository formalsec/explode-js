const a = require("node-latex-pdf");
try {
  a("./", "& touch node-latex-pdf", function () {});
} catch (err) {}
