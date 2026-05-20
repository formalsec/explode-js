const esl = require("esl_symbolic");
const root = require("@rkesters/gnuplot");
root.plot({
  data: [3, 1, 2, 3, 4],
  filename: esl.string("filename"),
  format: esl.string("format"),
});
