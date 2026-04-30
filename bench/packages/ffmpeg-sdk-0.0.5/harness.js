const esl = require('esl_symbolic');
const root = require("ffmpeg-sdk");
try {
  root.execute(esl.string('payload'));
} catch (err) {}
