const esl = require("esl_symbolic");
Promise.promisify = require("util").promisify;
require.cache[require.resolve("bluebird")] = { exports: Promise };

const dependencyVersions = require("npm-dependency-versions");
dependencyVersions({ "pkgs": [esl.string("payload")] })
