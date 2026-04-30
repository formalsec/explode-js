const git = require("git-lib");
try {
  git.add("test;touch git-lib;");
} catch (error) {}
