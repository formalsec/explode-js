var compileSass = require('broccoli-compass');
var user_provided_filename = '$(touch success);#';
compileSass({}, {
  files: [user_provided_filename]
}).write('.', '.');
