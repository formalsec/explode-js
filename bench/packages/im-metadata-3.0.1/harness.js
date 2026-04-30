const esl = require('esl_symbolic');
const metadata = require("im-metadata");
try {
  metadata(esl.string('payload'), { exif: true }, function (error, metadata) {});
} catch (err) {}
