const ffmpegdotjs = require("ffmpegdotjs");
const esl = require('esl_symbolic');
try {
  ffmpegdotjs.trimvideo("package-lock.json", 0, 30, esl.string('payload'));
} catch (err) {}
