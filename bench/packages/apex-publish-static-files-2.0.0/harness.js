
const publisher = require("apex-publish-static-files");
const esl = require('esl_symbolic');
publisher.publish({
  connectString: [esl.string('payload')],
  directory: "./",
  appID: 111,
});
