const esl = require("esl_symbolic");
require.cache[require.resolve("asyncc")] = { exports: esl.lazy_object() };

const GitFn = require("versionn")._.GitFn;
let g = new GitFn(esl.string("version"), { dir: "./" });
g.tag(() => {});
