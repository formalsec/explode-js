const esl = require("esl_symbolic");
const { plot } = require('@stoqey/gnuplot');
plot({
  data: [1, 2, 3],
  filename: esl.string("filename"),
  format: 'svg'
});
