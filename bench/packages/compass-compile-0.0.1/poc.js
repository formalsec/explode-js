const Root = require("compass-compile");
let root = new Root();
let options = { compassCommand: "touch compass-compile" };
try {
  root.compile(options).then(() => {}).catch((err) => {});
} catch (err) {}
