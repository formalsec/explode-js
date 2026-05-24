var esl = require("esl_symbolic");
require.cache[require.resolve("tmp")] = { exports : esl.lazy_object() };

var root = require("git-diff-apply");
root({remoteUrl: esl.string("remoteUrl"), startTag: esl.string("startTag")})
