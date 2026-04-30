const Git = require("git").Git;
let repo = new Git("repo-test");
let user_input = "; touch git";
try {
  repo.git(user_input, function (err, result) {});
} catch (error) {}
