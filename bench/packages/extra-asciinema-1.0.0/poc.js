const asciinema = require("extra-asciinema");
try {
  asciinema.uploadSync("; touch extra-asciinema");
} catch (err) {}
