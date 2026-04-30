const Root = require("effect");
var options = { image: "& touch effect" };
try {
  Root.edge(options, () => {});
} catch (err) {}
