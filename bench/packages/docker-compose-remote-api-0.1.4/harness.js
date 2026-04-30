const esl = require('esl_symbolic');
const root = require("docker-compose-remote-api");
try {
  root({ cwd: __dirname }).exec(esl.string('payload'), esl.string('payload2'),
    () => {},
    () => {},
    () => {}
  );
} catch (err) {}
