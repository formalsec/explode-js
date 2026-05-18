var esl = require("esl_symbolic");
require.cache[require.resolve("monorepo-repkg/lib/util/packages")] = {exports : esl.lazy_object() };

var a = require("monorepo-build");
a.build("./", esl.string("payload"));
