const root = require("@rkesters/gnuplot");
root.plot({
  data: [3, 1, 2, 3, 4],
  filename: __dirname + "/test/output1.png & touch success",
  format: "png",
});
