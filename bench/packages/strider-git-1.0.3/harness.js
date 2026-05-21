const esl = require("esl_symbolic");
const git = require("strider-git/lib");

var auth_type = esl.string("type");
esl.assume(auth_type !== "ssh");
git.getBranches(
  {
    auth: {
      type: auth_type,
      privkey: "sss",
    },
    url: "http://sss",
  },
  "",
  function () { }
);
