const killing = require("killing");
try {
  killing("$(touch killing & exit 1)");
} catch (err) {}
