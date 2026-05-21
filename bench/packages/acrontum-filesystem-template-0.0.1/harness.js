const esl = require("esl_symbolic");
require.cache[require.resolve("@acrontum/filesystem-template/dist/src/cli.js")] = {
  exports: esl.lazy_object()
};

const filesys = require("@acrontum/filesystem-template");
filesys.fetchRepo({ pathname: "/api/1", href: esl.string("href"), search: "456" });
