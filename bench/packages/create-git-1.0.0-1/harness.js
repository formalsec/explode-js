const esl = require("esl_symbolic");
// Stub requires not used.
require.cache[require.resolve("opta")] = { exports : esl.lazy_object() };
require.cache[require.resolve("got")] = { exports : esl.lazy_object() };
require.cache[require.resolve("inquirer")] = { exports : esl.lazy_object() };
require.cache[require.resolve("loggerr")] = { exports : esl.lazy_object() };
require.cache[require.resolve("parse-gitignore")] = { exports : esl.lazy_object() };

const createGit = require('create-git');
createGit.execGit([ esl.string("payload") ], { cwd : "./" });

