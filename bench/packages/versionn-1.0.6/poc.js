const GitFn = require("versionn")._.GitFn;
let g = new GitFn("0; touch success", { dir: "./" });
g.tag(() => {});
