let esl = require("esl_symbolic");
require.cache[require.resolve("chalk")] = { exports: esl.lazy_object() };
require.cache[require.resolve("optimist")] = { exports: esl.lazy_object() };

let spritesheet = require("lycwed-spritesheetjs");
spritesheet(
  "./",
  {
    fuzz: esl.string("fuzz"),
    ext: "json",
  },
  function () {
  }
);
