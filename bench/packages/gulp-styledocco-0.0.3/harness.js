var esl = require("esl_symbolic");
var root = require("gulp-styledocco");
var gulp = require("gulp");
var options = {
  opt: 'docs',
  name: esl.string("name")
}
gulp.src("./harness.js").pipe(root(options));
