var esl = require("esl_symbolic");
var ffmpegdotjs = require("ffmpegdotjs");

ffmpegdotjs.trimvideo(
  "package-lock.json",
  esl.number("start"),
  esl.number("duration"),
  esl.string("output")
).then((file) => {
  console.log(file);
});
